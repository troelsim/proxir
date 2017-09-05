# Proxir

A simple TCP proxy written in elixir. It listens on a specified port, and when a client connects, it connects to a specified remote server and forwards the traffic. A simple filter pipeline allows the traffic to be modified per line in either direction using your own code.

Currently, it works best for filtering text-only protocols such as uncompressed HTTP. The goal is a more sophisticated pipeline similar to Plug.

## Installation

Clone this git repo.

To run proxir from the command line:

```bash
$ mix escript.build
$ ./proxir <local_port> <remote_host> <remote_port>
```

To use it in your project, specify your filter module in your config file

```elixir
config :proxir,
    filter_module: YourApp.YourFilterModule
```

Your filter module must implement `filter_send(line)` and `filter_recv(line)`

Start the application like this:
```elixir
Proxir.Application.start(:normal, [port: 8080, host: "localhost", remote_port: 9000])
```

And Proxir will listen on port 8080 and forward the TCP connections to `localhost`, port 9000

## License
[Apache License 2.0](LICENSE)
