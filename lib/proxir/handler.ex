defmodule Proxir.Handler do
  @moduledoc """
  A GenServer to handle each incoming connection.
  """
  use GenServer
  require Logger
  @socket_module Application.get_env(:proxir, :socket_module, Proxir.Socket.Default)
  @filter_module Application.get_env(:proxir, :filter_module, Proxir.Filter)

  def start_link(client, opts) do
    GenServer.start_link(__MODULE__, [client, opts])
  end

  def init([client, opts]) do
    Logger.debug("Incoming connection")
    {:ok, %{client: client, opts: opts}}
  end

  def handle_info({:tcp, socket, data}, state = %{remote: remote, client: client}) do
    case socket do
      ^remote -> write_line(data |> @filter_module.filter_recv, client)
      ^client -> write_line(data |> @filter_module.filter_send, remote)
    end
    {:noreply, state}
  end
  def handle_info({:tcp, socket, data}, state = %{opts: opts}) do
    Logger.debug("Handling :tcp message")
    Logger.debug(inspect(@socket_module))
    {:ok, remote} = @socket_module.connect(opts)
    :inet.setopts(remote, active: true)
    handle_info({:tcp, socket, data}, state |> Map.put(:remote, remote))
  end
  def handle_info({:tcp_closed, _socket}, _state) do
    exit(:normal)
  end

  def handle_cast({:set_active}, state = %{client: client}) do
    :inet.setopts(client, active: true)
    {:noreply, state}
  end

  defp write_line({:error, _}, socket) do
    :gen_tcp.shutdown(socket, :write)
    exit(:shutdown)
  end
  defp write_line(data, socket) do
    :gen_tcp.send(socket, data)
  end
end
