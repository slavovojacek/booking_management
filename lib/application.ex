defmodule BookingManagement.Application do
  @moduledoc false

  alias BookingManagement.Producers.AirlineRequestProducer
  alias MQ.Supervisor, as: MQSupervisor

  use Application

  def start(_type, _args) do
    children = [
      {MQSupervisor, mq_opts()}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BookingManagement.Supervisor)
  end

  defp mq_opts,
    do: [
      producers: [
        {AirlineRequestProducer, workers: 1}
      ]
    ]
end
