# Proxir

A simple TCP proxy written in elixir. It listens on a specified port, and when a client connects, it connects to a specified remote server and forwards the traffic. A simple filter pipeline allows the traffic to be modified in either direction using your own code.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `proxir` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:proxir, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/proxir](https://hexdocs.pm/proxir).

