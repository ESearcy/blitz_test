defmodule Blitz.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BlitzWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:blitz, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Blitz.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Blitz.Finch},
      RiotApi.Supervisor,
      Blitz.Supervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Blitz.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlitzWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
