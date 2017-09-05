# Proxir

A simple TCP proxy written in elixir. It listens on a specified port, and when a client connects, it connects to a specified remote server and forwards the traffic. A simple filter pipeline allows the traffic to be modified per line in either direction using your own code.

Currently, it works best for filtering text-only protocols such as uncompressed HTTP. The goal is a more sophisticated pipeline similar to Plug.

## Installation

Clone this git repo.

```bash
$ mix escript.build
$ ./proxir <local_port> <remote_host> <remote_port>
```

## License
[Apache License 2.0](LICENSE)
