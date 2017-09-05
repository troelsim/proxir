defmodule Proxir do
  @moduledoc """
  Documentation for Proxir.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proxir.hello
      :world

  """

  def main(args) do
    IO.puts("In main")
    parse_args(args)
  end

  def parse_args([port, host, remote_port]) when
      is_integer(port) and
      is_binary(host) and
      is_integer(remote_port)
  do
    #Proxir.ProxyServer.start(:server, [port: port])
  end
  def parse_args([port, host, remote_port]) do
    try do
      parse_args([String.to_integer(port), host, String.to_integer(remote_port)])
    rescue
      ArgumentError -> parse_args(nil)
    end
  end
  def parse_args(_) do
    IO.puts("""
    Usage:
    proxir <port> <remote_host> <remote_port>
    """)
  end
end
