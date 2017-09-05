defmodule Proxir.Server do
  @moduledoc """
  A TCP server module that listens on a specified port and spawns new Tasks
  for each new connection
  """
  use GenServer, restart: :permanent
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def init(args) do
    GenServer.cast(self(), {:listen})
    {:ok, args |> Enum.into(%{})}
  end

  def handle_cast({:listen}, state) do
    accept(state)
    {:noreply, state}
  end

  def accept(opts = %{port: port}) do
    # Accept connections in passive mode, we switch to active
    # once we've handed over the connection to the handler process
    {:ok, socket} = :gen_tcp.listen(port,
          [:binary, active: false, reuseaddr: true, nodelay: true])
    Logger.debug("Listening on port #{port}")
    loop_acceptor(socket, opts)
  end

  defp loop_acceptor(socket, opts) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Proxir.HandlerSupervisor.start_handler(client, opts)
    :ok = :gen_tcp.controlling_process(client, pid)
    # Set the socket as active after we've handed over ownership
    GenServer.cast(pid, {:set_active})
    loop_acceptor(socket, opts)
  end
end
