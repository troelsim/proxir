defmodule Proxir.HandlerSupervisor do
  use Supervisor
  def start_link(args) do
    Supervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  def start_handler(client, opts) do
    Supervisor.start_child(__MODULE__, [client, opts])
  end

  def init(_) do
    supervise([
      worker(Proxir.Handler, [])
    ], strategy: :simple_one_for_one)
  end
end
