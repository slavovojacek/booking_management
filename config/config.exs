use Mix.Config

config :logger, handle_otp_reports: false

:logger.add_primary_filter(
  :ignore_rabbitmq_progress_reports,
  {&:logger_filters.domain/2, {:stop, :equal, [:progress]}}
)

config :rabbit_mq_ex, :topology, [
  {"airline_request",
   type: :topic,
   durable: true,
   routing_keys: [
     {"*.request_fares",
      queue: "airline_request_queue/*.request_fares/airline_integrations",
      durable: true,
      dlq: "airline_request_dead_letter_queue"}
   ]}
]

import_config "#{Mix.env()}.exs"
