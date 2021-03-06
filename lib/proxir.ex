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
    parse_args(args)
  end

  def parse_args([port, host, remote_port]) when
      is_integer(port) and
      is_binary(host) and
      is_integer(remote_port)
  do
    Proxir.Application.start(:normal, [port: port, host: host, remote_port: remote_port])
    # Wait indefinitely, otherwise process will quit immediately
    receive do
      _ -> nil
    end
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
