defmodule Wynix.ContractsTest do
  use Wynix.DataCase

  alias Wynix.Contracts

  describe "orders" do
    alias Wynix.Contracts.Order

    @valid_attrs %{amount: 120.5, bid_deadline: ~D[2010-04-17], contractors_needed: 42, currency: "some currency", description: "some description", order_category: "some order_category", order_code: "some order_code", order_length: "some order_length", order_type: "some order_type", payment_at: "some payment_at", proposal_required: true, status: "some status"}
    @update_attrs %{amount: 456.7, bid_deadline: ~D[2011-05-18], contractors_needed: 43, currency: "some updated currency", description: "some updated description", order_category: "some updated order_category", order_code: "some updated order_code", order_length: "some updated order_length", order_type: "some updated order_type", payment_at: "some updated payment_at", proposal_required: false, status: "some updated status"}
    @invalid_attrs %{amount: nil, bid_deadline: nil, contractors_needed: nil, currency: nil, description: nil, order_category: nil, order_code: nil, order_length: nil, order_type: nil, payment_at: nil, proposal_required: nil, status: nil}

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contracts.create_order()

      order
    end

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Contracts.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Contracts.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Contracts.create_order(@valid_attrs)
      assert order.amount == 120.5
      assert order.bid_deadline == ~D[2010-04-17]
      assert order.contractors_needed == 42
      assert order.currency == "some currency"
      assert order.description == "some description"
      assert order.order_category == "some order_category"
      assert order.order_code == "some order_code"
      assert order.order_length == "some order_length"
      assert order.order_type == "some order_type"
      assert order.payment_at == "some payment_at"
      assert order.proposal_required == true
      assert order.status == "some status"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contracts.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, %Order{} = order} = Contracts.update_order(order, @update_attrs)
      assert order.amount == 456.7
      assert order.bid_deadline == ~D[2011-05-18]
      assert order.contractors_needed == 43
      assert order.currency == "some updated currency"
      assert order.description == "some updated description"
      assert order.order_category == "some updated order_category"
      assert order.order_code == "some updated order_code"
      assert order.order_length == "some updated order_length"
      assert order.order_type == "some updated order_type"
      assert order.payment_at == "some updated payment_at"
      assert order.proposal_required == false
      assert order.status == "some updated status"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Contracts.update_order(order, @invalid_attrs)
      assert order == Contracts.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Contracts.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Contracts.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Contracts.change_order(order)
    end
  end

  describe "bids" do
    alias Wynix.Contracts.Bid

    @valid_attrs %{asking_amount: 120.5, deposit_amount: 120.5, owner_name: "some owner_name", status: "some status"}
    @update_attrs %{asking_amount: 456.7, deposit_amount: 456.7, owner_name: "some updated owner_name", status: "some updated status"}
    @invalid_attrs %{asking_amount: nil, deposit_amount: nil, owner_name: nil, status: nil}

    def bid_fixture(attrs \\ %{}) do
      {:ok, bid} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contracts.create_bid()

      bid
    end

    test "list_bids/0 returns all bids" do
      bid = bid_fixture()
      assert Contracts.list_bids() == [bid]
    end

    test "get_bid!/1 returns the bid with given id" do
      bid = bid_fixture()
      assert Contracts.get_bid!(bid.id) == bid
    end

    test "create_bid/1 with valid data creates a bid" do
      assert {:ok, %Bid{} = bid} = Contracts.create_bid(@valid_attrs)
      assert bid.asking_amount == 120.5
      assert bid.deposit_amount == 120.5
      assert bid.owner_name == "some owner_name"
      assert bid.status == "some status"
    end

    test "create_bid/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contracts.create_bid(@invalid_attrs)
    end

    test "update_bid/2 with valid data updates the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{} = bid} = Contracts.update_bid(bid, @update_attrs)
      assert bid.asking_amount == 456.7
      assert bid.deposit_amount == 456.7
      assert bid.owner_name == "some updated owner_name"
      assert bid.status == "some updated status"
    end

    test "update_bid/2 with invalid data returns error changeset" do
      bid = bid_fixture()
      assert {:error, %Ecto.Changeset{}} = Contracts.update_bid(bid, @invalid_attrs)
      assert bid == Contracts.get_bid!(bid.id)
    end

    test "delete_bid/1 deletes the bid" do
      bid = bid_fixture()
      assert {:ok, %Bid{}} = Contracts.delete_bid(bid)
      assert_raise Ecto.NoResultsError, fn -> Contracts.get_bid!(bid.id) end
    end

    test "change_bid/1 returns a bid changeset" do
      bid = bid_fixture()
      assert %Ecto.Changeset{} = Contracts.change_bid(bid)
    end
  end
end
