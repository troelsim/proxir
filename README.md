# Proxir

A simple TCP proxy written in elixir. It listens on a specified port, and when a client connects, it connects to a specified remote server and forwards the traffic. A simple filter pipeline allows the traffic to be modified per line in either direction using your own code.

Currently, it works best for filtering text-only protocols such as uncompressed HTTP. The goal is a more sophisticated pipeline similar to Plug.

You can for example use it for debugging web and mobile applications, or security auditing.

Suppose you want to pipe the traffic from a local application to `example.com` through Proxir: You can add `127.0.0.1 example.com` to `/etc/hosts` and have Proxir listen on localhost, port 80, forwarding the traffic to example.com, port 80.

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
