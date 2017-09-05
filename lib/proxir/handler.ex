defmodule Proxir.Handler do
  @moduledoc """
  A GenServer to handle each incoming connection
  """
  use GenServer

  def start_link([opts]) do
    GenServer.start_link(__MODULE__, [opts])
  end

  def init([opts]) do
    {:ok, remote} = connect(opts)
    {:ok, %{remote: remote}}
  end

  def connect(%{host: host, remote_port: remote_port}) do
    IO.puts("Connecting to #{host}:#{remote_port}...")
    :gen_tcp.connect(String.to_charlist(host), remote_port, [:binary, active: false, reuseaddr: true, nodelay: true])
  end

  def handle_info({:tcp, socket, data}, state = %{remote: remote, client: client}) do
    IO.puts("handle_info tcp")
    case socket do
      ^remote -> write_line(data, client)
      ^client -> write_line(data, remote)
    end
    {:noreply, state}
  end
  def handle_info({:tcp_closed, _socket}, _state) do
    exit(:normal)
  end

  def handle_cast({:set_client, client},  state = %{remote: remote}) do
    GenServer.cast(self, {:set_client_socket, client})
    GenServer.cast(self, {:set_active})
    {:noreply, state |> Map.put(:client, client)}
  end
  def handle_cast({:set_client_socket, client},  state) do
    {:noreply, Map.put(state, :client, client)}
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
