defmodule Proxir.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications

  use Application

  def start(_type, [port: port, host: host, remote_port: remote_port]) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(Proxir.HandlerSupervisor, [[name: Proxir.HandlerSupervisor]]),
      worker(Proxir.Server, [%{port: port, host: host, remote_port: remote_port}], restart: :permanent),
      #worker(Task, [Proxir.Server, :accept,
      #  [%{port: port, host: host, remote_port: remote_port}]]
      #)
      ]
    opts = [strategy: :one_for_one, name: Proxir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
