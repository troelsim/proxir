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

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Proxir.Worker.start_link(arg1, arg2, arg3)
      # worker(Proxir.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Proxir.Supervisor]
    IO.puts("Starting application")
    Supervisor.start_link(children, opts)
  end
end
