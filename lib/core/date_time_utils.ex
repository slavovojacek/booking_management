defmodule Core.DateTimeUtils do
  @moduledoc """
  Re-usable DateTime utilities.
  """

  @spec iso_8601_to_day_beginning!(String.t()) :: DateTime.t()
  def iso_8601_to_day_beginning!(iso_8601) do
    iso_8601
    |> Timex.parse!("{ISO:Extended}")
    |> Timex.beginning_of_day()
  end
end
