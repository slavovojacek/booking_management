defmodule Events.V1.PlaceBooking do
  @moduledoc """
  Defines the Place Booking (v1) event.
  """

  @derive Jason.Encoder
  @enforce_keys [:airline_code, :airline_fare_id]
  defstruct version: "1.0.0",
            airline_code: nil,
            airline_fare_id: nil

  @type t() :: %__MODULE__{
          version: String.t(),
          airline_code: String.t(),
          airline_fare_id: String.t()
        }
end
