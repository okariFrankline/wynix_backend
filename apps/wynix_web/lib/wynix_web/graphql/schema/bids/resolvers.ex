defmodule WynixWeb.Schema.Bids.Resolver do
  alias Wynix
  alias Wynix.{Contracts}

  @doc false
  def place_bid(_parent, %{practise_name: name, practise_id: prac_id, order_id: order_id, input: input}, _resolution) do
    with {:ok, _bid} = result <- Wynix.create_bid(name, prac_id, order_id, input) do
      # return result
      result
    else
      {:error, :cacelled_order} ->
        errors = [%{
          key: "Cancelled Order",
          message: "Failed. Order has been cancelled"
        }]
        # return result
        {:ok, %{errors: errors}}
    end # end of with
  end # end of the place bid
end # end of the bid resolver module
