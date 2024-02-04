defmodule RiotApi.Supervisor do
  use Supervisor

  def start_link(state) do
    Supervisor.start_link(__MODULE__, state)
  end

  @impl true
  def init(_state \\ %{}) do
    children = [
      Supervisor.child_spec({Cachex, :summoners}, id: :s_cache),
      Supervisor.child_spec({Cachex, :matches}, id: :m_cache),
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
