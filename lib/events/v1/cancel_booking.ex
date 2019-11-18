defmodule Events.V1.CancelBooking do
  @moduledoc """
  Defines the Cancel Booking (v1) event.
  """

  @derive Jason.Encoder
  @enforce_keys [:airline_code, :airline_booking_id]
  defstruct version: "1.0.0",
            airline_code: nil,
            airline_booking_id: nil

  @type t() :: %__MODULE__{
          version: String.t(),
          airline_code: String.t(),
          airline_booking_id: String.t()
        }
end
