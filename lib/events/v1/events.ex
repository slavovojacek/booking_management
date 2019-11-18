defmodule Events.V1 do
  @moduledoc """
  Generates the specific events to be published
  by the `AirlineRequestProducer`.
  """

  alias Events.V1.RequestFares

  @spec request_fares(map()) :: RequestFares.t()
  def request_fares(
        %{
          departure_date_time: %DateTime{} = departure_date_time,
          return_date_time: %DateTime{} = return_date_time
        } = attrs
      ) do
    %RequestFares{
      type: attrs.type,
      number_of_passengers: attrs.number_of_passengers,
      class: attrs.class,
      from: attrs.from,
      to: attrs.to,
      departure_date_time: DateTime.to_iso8601(departure_date_time),
      return_date_time: DateTime.to_iso8601(return_date_time)
    }
  end

  def request_fares(%{departure_date_time: %DateTime{} = departure_date_time} = attrs) do
    %RequestFares{
      type: attrs.type,
      number_of_passengers: attrs.number_of_passengers,
      class: attrs.class,
      from: attrs.from,
      to: attrs.to,
      departure_date_time: DateTime.to_iso8601(departure_date_time)
    }
  end

  @spec place_booking() :: {:error, :not_implemented}
  def place_booking(), do: {:error, :not_implemented}

  @spec cancel_booking() :: {:error, :not_implemented}
  def cancel_booking(), do: {:error, :not_implemented}
end
