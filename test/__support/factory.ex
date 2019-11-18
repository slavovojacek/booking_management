defmodule TestSupport.Factory do
  @moduledoc """
  Contains all `ExMachina` factories.

  See https://github.com/thoughtbot/ex_machina for more details on usage.
  """

  use ExMachina

  @supported_airports ~w(SIN HND ICN DOH HKG NGO MUC LHR NRT ZRH KIX FRA TPE AMS CPH)

  def request_fares_params_factory do
    from = Enum.random(@supported_airports)
    to = @supported_airports |> Enum.reject(&(&1 == from)) |> Enum.random()
    departure_date_time = DateTime.utc_now()
    return_date_time = departure_date_time |> DateTime.add(172_800, :second)

    %{
      "type" => Enum.random(["one_way", "return"]),
      "number_of_passengers" => :rand.uniform(48),
      "class" => Enum.random(["economy", "premium"]),
      "from" => from,
      "to" => to,
      "departure_date_time" => DateTime.to_iso8601(departure_date_time),
      "return_date_time" => DateTime.to_iso8601(return_date_time)
    }
  end
end
