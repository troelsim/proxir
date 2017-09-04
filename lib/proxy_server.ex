defmodule Proxir.ProxyServer do
  use Application
  @moduledoc """
  A TCP server module that listens on a specified port and spawns new Tasks
  for each new connection
  """

  def start(_type, [port: port]) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: Proxir.TaskSupervisor]]),
      worker(Task, [Proxir.ProxyServer, :accept, [port]])
    ]
    opts = [strategy: :one_for_one, name: Proxir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(port) do
    IO.puts "Waiting for connections on port #{port}"
    {:ok, socket} = :gen_tcp.listen(port,
          [:binary, packet: :line, active: false, reuseaddr: true])
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    IO.puts "Got new connection"
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Proxir.TaskSupervisor, fn -> serve(client) end)
    IO.inspect(pid)
    loop_acceptor(socket)
  end

  defp serve(socket) do
    socket |> read_line() |> write_line(socket)
    serve(socket)
  end

  defp read_line(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)
    data
  end
  defp write_line(line, socket) do
    :gen_tcp.send(socket, line)
  end
end
