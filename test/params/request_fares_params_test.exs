defmodule ParamsTest.RequestFaresParams do
  @moduledoc false

  alias Params.RequestFaresParams
  alias TestSupport.Factory

  import Core.DateTimeUtils, only: [iso_8601_to_day_beginning!: 1]

  use ExUnit.Case, async: true

  @supported_airports RequestFaresParams.supported_airports()

  describe "Params.RequestFaresParams" do
    test "to_valid_attrs/1 returns valid attrs" do
      params = Factory.build(:request_fares_params)

      assert {:ok, attrs} = RequestFaresParams.to_valid_attrs(params)

      assert attrs.class == params["class"]

      assert attrs.departure_date_time ==
               iso_8601_to_day_beginning!(params["departure_date_time"])

      assert attrs.from == params["from"]
      assert attrs.number_of_passengers == params["number_of_passengers"]

      assert attrs.return_date_time ==
               iso_8601_to_day_beginning!(params["return_date_time"])

      assert attrs.to == params["to"]
      assert attrs.type == params["type"]
    end

    test "to_valid_attrs/1 returns transforms ISO8601 strings to beginning of day (as `DateTime`)" do
      params = Factory.build(:request_fares_params)

      assert {:ok,
              %{
                departure_date_time: %DateTime{} = departure_date_time,
                return_date_time: %DateTime{} = return_date_time
              }} = RequestFaresParams.to_valid_attrs(params)

      assert departure_date_time ==
               params["departure_date_time"]
               |> Timex.parse!("{ISO:Extended}")
               |> Timex.beginning_of_day()

      assert return_date_time ==
               params["return_date_time"]
               |> Timex.parse!("{ISO:Extended}")
               |> Timex.beginning_of_day()
    end

    test "to_valid_attrs/1 returns a validation error if `return_date_time` is not present on a return flight" do
      params =
        Factory.build(:request_fares_params, %{"type" => "return", "return_date_time" => nil})

      assert {:error, %Ecto.Changeset{errors: errors, valid?: false}} =
               RequestFaresParams.to_valid_attrs(params)

      assert [return_date_time: {"cannot be empty", []}] = errors
    end

    test "to_valid_attrs/1 returns a validation error if `return_date_time` is on or before `departure_date_time`" do
      today = DateTime.utc_now() |> DateTime.to_iso8601()

      params =
        Factory.build(:request_fares_params, %{
          "type" => "return",
          "departure_date_time" => today,
          "return_date_time" => today
        })

      assert {:error, %Ecto.Changeset{errors: errors, valid?: false}} =
               RequestFaresParams.to_valid_attrs(params)

      assert [return_date_time: {"must be after departure date", []}] = errors
    end

    test "to_valid_attrs/1 returns a validation errors if invalid params are provided" do
      params =
        Factory.build(:request_fares_params, %{
          "type" => "unsupported_type",
          "number_of_passengers" => "invalid_arg",
          "class" => "unsupported_class",
          "from" => "unsupported_airport_code",
          "to" => "unsupported_airport_code",
          "departure_date_time" => "invalid_date_time",
          "return_date_time" => "invalid_date_time"
        })

      assert {:error, %Ecto.Changeset{errors: errors, valid?: false}} =
               RequestFaresParams.to_valid_attrs(params)

      assert {"is invalid", [validation: :inclusion, enum: ["one_way", "return"]]} =
               errors |> Keyword.get(:type)

      assert {"is invalid", [type: :integer, validation: :cast]} =
               errors |> Keyword.get(:number_of_passengers)

      assert {"is invalid", [validation: :inclusion, enum: ["economy", "premium"]]} =
               errors |> Keyword.get(:class)

      assert {"is invalid", [validation: :inclusion, enum: @supported_airports]} =
               errors |> Keyword.get(:from)

      assert {"is invalid",
              [
                validation: :inclusion,
                enum: @supported_airports
              ]} = errors |> Keyword.get(:to)

      assert {"has invalid format", [validation: :format]} =
               errors |> Keyword.get(:departure_date_time)

      assert {"has invalid format", [validation: :format]} =
               errors |> Keyword.get(:return_date_time)
    end
  end
end
