defmodule Memex.MoneyPenny do
  use Supervisor

  def start_link(params) do
    Supervisor.start_link(__MODULE__, params, name: __MODULE__)
  end

  @impl true
  def init(env_map) do

    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Agent.DynamicSupervisor},
      Memex.Agents.BackupAgent,
      Memex.Agents.StrategicAdvisor
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end