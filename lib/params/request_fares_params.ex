defmodule Params.RequestFaresParams do
  @moduledoc """
  Validates the presence and shape of params
  needed to request fares from airlines.
  """

  use Params.Schema

  import Ecto.Changeset,
    only: [add_error: 3, cast: 3, put_change: 3, validate_format: 3, validate_inclusion: 3]

  @supported_types ~w(one_way return)
  @supported_classes ~w(economy premium)
  @supported_airports ~w(SIN HND ICN DOH HKG NGO MUC LHR NRT ZRH KIX FRA TPE AMS CPH)

  @iso_8601_regex ~r/^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9])T(2[0-3]|[01][0-9]):([0-5][0-9]):([0-5][0-9])(.[0-9]+)?(Z)?$/

  @cast ~w(type number_of_passengers class from to departure_date_time return_date_time)a
  @required ~w(type number_of_passengers class from to departure_date_time)

  schema do
    field(:type, :string)
    field(:number_of_passengers, :integer)
    field(:class, :string)
    field(:from, :string)
    field(:to, :string)
    field(:departure_date_time, :string)
    field(:return_date_time, :string)
  end

  @spec to_valid_attrs(map()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}
  def to_valid_attrs(params) do
    params
    |> from(with: &changeset/2)
    |> case do
      %Ecto.Changeset{valid?: true} = changeset -> {:ok, Params.to_map(changeset)}
      changeset -> {:error, changeset}
    end
  end

  @spec changeset(map(), map()) :: Ecto.Changeset.t()
  def changeset(changeset, params) do
    changeset
    |> cast(params, @cast)
    |> validate_inclusion(:type, @supported_types)
    |> validate_inclusion(:class, @supported_classes)
    |> validate_inclusion(:from, @supported_airports)
    |> validate_inclusion(:to, @supported_airports)
    |> validate_format(:departure_date_time, @iso_8601_regex)
    |> validate_format(:return_date_time, @iso_8601_regex)
    |> convert_iso_8601_to_day_beginning()
    |> validate_return_date()
  end

  @spec supported_airports() :: list(String.t())
  def supported_airports, do: @supported_airports

  defp convert_iso_8601_to_day_beginning(
         %{
           changes: %{
             departure_date_time: departure_date_time,
             return_date_time: return_date_time
           },
           valid?: true
         } = changeset
       ) do
    changeset
    |> put_change(:departure_date_time, iso_8601_to_day_beginning!(departure_date_time))
    |> put_change(:return_date_time, iso_8601_to_day_beginning!(return_date_time))
  end

  defp convert_iso_8601_to_day_beginning(
         %{changes: %{departure_date_time: departure_date_time}, valid?: true} = changeset
       ),
       do:
         put_change(
           changeset,
           :departure_date_time,
           iso_8601_to_day_beginning!(departure_date_time)
         )

  defp convert_iso_8601_to_day_beginning(changeset), do: changeset

  defp validate_return_date(
         %{
           changes: %{
             type: "return",
             departure_date_time: departure_date_time,
             return_date_time: return_date_time
           }
         } = changeset
       ) do
    case Timex.before?(departure_date_time, return_date_time) do
      true -> changeset
      _ -> add_error(changeset, :return_date_time, "must be after departure date")
    end
  end

  defp validate_return_date(%{changes: %{type: "return"}} = changeset) do
    add_error(changeset, :return_date_time, "cannot be empty")
  end

  defp validate_return_date(changeset), do: changeset

  defp iso_8601_to_day_beginning!(iso_8601) do
    iso_8601
    |> Timex.parse!("{ISO:Extended}")
    |> Timex.beginning_of_day()
  end
end
