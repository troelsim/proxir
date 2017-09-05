defmodule Proxir.Server do
  @moduledoc """
  A TCP server module that listens on a specified port and spawns new Tasks
  for each new connection
  """
  use GenServer, restart: :permanent

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    GenServer.cast(self, {:listen})
    {:ok, args |> Enum.into(%{})}
  end

  def handle_cast({:listen}, state) do
    accept(state)
    {:noreply, state}
  end

  def accept(opts = %{port: port}) do
    IO.puts "Waiting for connections on port #{port}"
    {:ok, socket} = :gen_tcp.listen(port,
          [:binary, active: false, reuseaddr: true, nodelay: true])
    loop_acceptor(socket, opts)
  end

  defp loop_acceptor(socket, opts = %{port: port}) do
    IO.puts "Listening on #{port}..."
    {:ok, client} = :gen_tcp.accept(socket)
    IO.puts "Got new connection, starting handler"
    {:ok, pid} = Proxir.HandlerSupervisor.start_handler([opts])
    IO.puts "Passing ownership to #{inspect(pid)}"
    :ok = :gen_tcp.controlling_process(client, pid)
    GenServer.cast(pid, {:set_client, client})
    IO.inspect(pid)
    loop_acceptor(socket, opts)
  end
end
