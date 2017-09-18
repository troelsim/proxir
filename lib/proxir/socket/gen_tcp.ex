defmodule Proxir.Socket.Default do
  require Logger

  def connect(%{host: host, remote_port: remote_port}) do
    Logger.debug("Connecting to #{host}:#{remote_port} using :gen_tcp...")
    IO.inspect(:gen_tcp.connect(String.to_charlist(host), remote_port, [:binary, active: true, reuseaddr: true, nodelay: true]))
  end
end
