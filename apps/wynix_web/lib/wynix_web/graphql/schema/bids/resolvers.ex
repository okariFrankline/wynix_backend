defmodule WynixWeb.Schema.Bids.Resolver do
  alias Wynix
  #alias Wynix.{Contracts}

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

  @doc false
  def reject_bid(_parent, args, _resolution) do
    # reject the bid
    with :ok <- Wynix.reject_bid(args.bid_id) do
      {:ok, %{message: "Bid Successfully deleted."}}
    end # end of with
  end # end  of reject_bid/3

  @doc false
  def cancel_bid(_parent, args, _resolution) do
    with {:ok, _bid} = result <- Wynix.cancel_bid(args.bid_id) do
      # returnt he results
      result
    else
      :accepted ->
        errors = [%{
          key: "Bid Accepted",
          message: "Failed. Bid has already being accepted."
        }]
        # return the results
        {:ok, %{errors: errors}}
    end # end of with for cancelling a bid
  end # end of cancel bid
end # end of the bid resolver module
