defmodule Proxir.ProxyTask do
  def serve(socket, %{host: host, remote_port: remote_port}) do
    IO.puts("Connection to #{host}:#{remote_port}")
    case :gen_tcp.connect(String.to_charlist(host), remote_port, [:binary, active: false, reuseaddr: true, nodelay: true]) do
      {:ok, remote} -> loop_serve(socket, remote)
      {:error, _} -> exit(:shutdown)
    end
  end

  defp loop_serve(client, remote) do
    message = with {:ok, data} <- read_line(client), do: data
    IO.puts("Client: ")
    IO.inspect(read_line(client)) |> write_line(remote)
    IO.puts("Remote:")
    IO.inspect(read_line(remote)) |> write_line(client)
    loop_serve(client, remote)
  end

  defp read_line(socket) do
    :gen_tcp.recv(socket, 0)
  end

  defp write_line({:error, _}, socket) do
    :gen_tcp.shutdown(socket, :write)
    exit(:shutdown)
  end
  defp write_line({:ok, data}, socket) do
    :gen_tcp.send(socket, data)
  end
end
