defmodule BookingManagementTest.Client do
  @moduledoc false

  alias BookingManagement.Client
  alias TestSupport.Factory
  alias MQ.Support.{RabbitCase, ExclusiveQueue, TestConsumer}

  import Core.DateTimeUtils, only: [iso_8601_to_day_beginning!: 1]

  use RabbitCase

  setup_all do
    # Make sure our tests receive all messages published to the `airline_request`
    # exchange, regardless of the `routing_key` configured (hence `#`).
    assert {:ok, airline_request_queue} =
             ExclusiveQueue.declare(exchange: "airline_request", routing_key: "#")

    # Start the `TestConsumer` module, which consumes messages from a given queue
    # and sends them to a process associated with a test that's being executed.
    #
    # See `TestConsumer.register_reply_to(self())` in the `setup` section below.
    assert {:ok, _pid} = start_supervised(TestConsumer.child_spec(queue: airline_request_queue))

    :ok
  end

  setup do
    # Each test process will register its pid (`self()`) so that we can receive
    # corresponding payloads and metadata published via the `Producer`(s).
    assert {:ok, reply_to} = TestConsumer.register_reply_to(self())

    # Each registration generates a unique identifier which will be used
    # in the `TestConsumer`'s message processor module to look up the pid
    # of the currently running test and send the payload and the metadata
    # to that process.
    publish_opts = [reply_to: reply_to]

    [publish_opts: publish_opts]
  end

  describe "BookingManagement.Client" do
    test "request_fares/2 publishes a valid `RequestFares` event", %{
      publish_opts: publish_opts
    } do
      params = Factory.build(:request_fares_params)

      assert :ok = Client.request_fares(params, publish_opts)

      assert_receive({:json, payload, %{routing_key: "*.request_fares"}}, 250)

      assert payload["class"] == params["class"]

      assert payload["departure_date_time"] ==
               iso_8601_to_day_beginning!(params["departure_date_time"]) |> DateTime.to_iso8601()

      assert payload["from"] == params["from"]
      assert payload["number_of_passengers"] == params["number_of_passengers"]

      assert payload["return_date_time"] ==
               iso_8601_to_day_beginning!(params["return_date_time"]) |> DateTime.to_iso8601()

      assert payload["to"] == params["to"]
      assert payload["type"] == params["type"]
      assert payload["version"] == "1.0.0"
    end

    test "request_fares/2 does not publish an invalid event" do
      params =
        Factory.build(:request_fares_params, %{"type" => "return", "return_date_time" => nil})

      assert {:error, %Ecto.Changeset{errors: [_ | _], valid?: false}} =
               Client.request_fares(params, [])

      refute_receive 100
    end

    test "place_booking/1 is not implemented" do
      assert {:error, :not_implemented} = Client.place_booking()
    end

    test "cancel_booking/1 is not implemented" do
      assert {:error, :not_implemented} = Client.cancel_booking()
    end
  end
end
