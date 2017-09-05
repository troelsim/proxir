defmodule Proxir.Handler do
  @moduledoc """
  A GenServer to handle each incoming connection.
  """
  use GenServer
  require Logger

  def start_link(client, opts) do
    GenServer.start_link(__MODULE__, [client, opts])
  end

  def init([client, opts]) do
    {:ok, remote} = connect(opts)
    {:ok, %{remote: remote, client: client}}
  end

  def connect(%{host: host, remote_port: remote_port}) do
    Logger.debug("Connecting to #{host}:#{remote_port}...")
    :gen_tcp.connect(String.to_charlist(host), remote_port, [:binary, active: false, reuseaddr: true, nodelay: true])
  end

  def handle_info({:tcp, socket, data}, state = %{remote: remote, client: client}) do
    filter_module = Application.get_env(:proxir, :filter_module)
    case socket do
      ^remote -> write_line(data |> filter_module.filter_recv, client)
      ^client -> write_line(data |> filter_module.filter_send, remote)
    end
    {:noreply, state}
  end
  def handle_info({:tcp_closed, _socket}, _state) do
    exit(:normal)
  end

  def handle_cast({:set_active}, state = %{remote: remote, client: client}) do
    :inet.setopts(client, active: true)
    :inet.setopts(remote, active: true)
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
