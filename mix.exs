defmodule BookingManagement.MixProject do
  use Mix.Project

  def project do
    [
      app: :booking_management,
      version: "0.1.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:ecto]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {BookingManagement.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(env) when env in [:test, :ci], do: ["lib", "test/__support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:params, "~> 2.0"},
      {:rabbit_mq_ex, "~> 1.0.0-1.0.5"},
      {:timex, "~> 3.5"},
      # Dev-only deps
      {:ex_check, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      # Test-only deps
      {:ex_machina, "~> 2.3", only: [:ci, :test]},
      {:excoveralls, "~> 0.10", only: :test}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      test: ["rabbit.init", "test"]
    ]
  end
end
