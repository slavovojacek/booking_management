defmodule BookingManagement.Producers.AirlineRequestProducer do
  @moduledoc """
  Defines functions that set up and publish messages onto
  the `airline_request` exchange.
  """

  alias Events.V1.RequestFares
  alias MQ.Producer

  use Producer, exchange: "airline_request"

  @spec request_fares(RequestFares.t(), keyword()) :: :ok
  def request_fares(%RequestFares{} = event, opts \\ []) when is_list(opts) do
    opts = Keyword.put(opts, :routing_key, "*.request_fares")
    payload = Jason.encode!(event)
    publish(payload, opts)
  end

  @spec place_booking() :: {:error, :not_implemented}
  def place_booking, do: {:error, :not_implemented}

  @spec cancel_booking() :: {:error, :not_implemented}
  def cancel_booking, do: {:error, :not_implemented}
end
