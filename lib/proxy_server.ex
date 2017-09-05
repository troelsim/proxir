defmodule Proxir.ProxyServer do
  use Application
  @moduledoc """
  A TCP server module that listens on a specified port and spawns new Tasks
  for each new connection
  """

  def start(_type, [port: port, host: host, remote_port: remote_port]) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Task.Supervisor, [[name: Proxir.TaskSupervisor]]),
      worker(Task, [Proxir.ProxyServer, :accept,
        [%{port: port, host: host, remote_port: remote_port}]]
      )
    ]
    opts = [strategy: :one_for_one, name: Proxir.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(opts = %{port: port}) do
    IO.puts "Waiting for connections on port #{port}"
    {:ok, socket} = :gen_tcp.listen(port,
          [:binary, active: false, reuseaddr: true, nodelay: true])
    loop_acceptor(socket, opts)
  end

  defp loop_acceptor(socket, opts = %{port: port}) do
    IO.puts "Got new connection"
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(Proxir.TaskSupervisor, fn ->
      Proxir.ProxyTask.serve(client, opts)
    end)
    IO.inspect(pid)
    loop_acceptor(socket, opts)
  end
end
