defmodule Events.V1.RequestFares do
  @moduledoc """
  Defines the Request Fares (v1) event.
  """

  @derive Jason.Encoder
  @enforce_keys [:type, :number_of_passengers, :class, :from, :to, :departure_date_time]
  defstruct version: "1.0.0",
            type: nil,
            number_of_passengers: nil,
            class: nil,
            from: nil,
            to: nil,
            departure_date_time: nil,
            return_date_time: nil

  @type t() :: %__MODULE__{
          version: String.t(),
          type: String.t(),
          number_of_passengers: integer(),
          class: String.t(),
          from: String.t(),
          to: String.t(),
          departure_date_time: String.t(),
          return_date_time: String.t() | nil
        }
end
