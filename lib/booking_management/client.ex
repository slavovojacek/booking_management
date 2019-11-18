defmodule BookingManagement.Client do
  @moduledoc """
  The client-facing interface. This can potentially be connected
  with the Phoenix framework.
  """

  alias BookingManagement.Producers.AirlineRequestProducer
  alias Params.RequestFaresParams
  alias Events.V1, as: Events

  @spec request_fares(map(), keyword()) :: :ok | {:error, Ecto.Changeset.t()}
  def request_fares(params, publish_opts \\ []) do
    with {:ok, attrs} <- RequestFaresParams.to_valid_attrs(params),
         event <- Events.request_fares(attrs) do
      AirlineRequestProducer.request_fares(event, publish_opts)
    end
  end

  @spec place_booking() :: {:error, :not_implemented}
  def place_booking, do: {:error, :not_implemented}

  @spec cancel_booking() :: {:error, :not_implemented}
  def cancel_booking, do: {:error, :not_implemented}
end
