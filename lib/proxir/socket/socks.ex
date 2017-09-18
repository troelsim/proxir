defmodule Proxir.Socket.SOCKS do
  require Socket
  require Logger
  @socks_host Application.get_env(:proxir, :socks_host, "127.0.0.1")
  @socks_port Application.get_env(:proxir, :socks_port, 9050)

  def connect(%{host: host, remote_port: port}) do
    Logger.debug("Connecting to #{host}:#{port} using SOCKS proxy at #{@socks_host}:#{@socks_port}")
    Socket.SOCKS.connect({host, port}, {@socks_host, @socks_port}, version: 4)
  end
end
