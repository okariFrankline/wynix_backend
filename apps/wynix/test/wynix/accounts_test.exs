defmodule Wynix.AccountsTest do
  use Wynix.DataCase

  alias Wynix.Accounts

  describe "users" do
    alias Wynix.Accounts.User

    @valid_attrs %{account_type: "some account_type", email: "some email", is_active: true, password_hash: "some password_hash", token: "some token", username: "some username"}
    @update_attrs %{account_type: "some updated account_type", email: "some updated email", is_active: false, password_hash: "some updated password_hash", token: "some updated token", username: "some updated username"}
    @invalid_attrs %{account_type: nil, email: nil, is_active: nil, password_hash: nil, token: nil, username: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.account_type == "some account_type"
      assert user.email == "some email"
      assert user.is_active == true
      assert user.password_hash == "some password_hash"
      assert user.token == "some token"
      assert user.username == "some username"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.account_type == "some updated account_type"
      assert user.email == "some updated email"
      assert user.is_active == false
      assert user.password_hash == "some updated password_hash"
      assert user.token == "some updated token"
      assert user.username == "some updated username"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "accounts" do
    alias Wynix.Accounts.Account

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def account_fixture(attrs \\ %{}) do
      {:ok, account} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_account()

      account
    end

    test "list_accounts/0 returns all accounts" do
      account = account_fixture()
      assert Accounts.list_accounts() == [account]
    end

    test "get_account!/1 returns the account with given id" do
      account = account_fixture()
      assert Accounts.get_account!(account.id) == account
    end

    test "create_account/1 with valid data creates a account" do
      assert {:ok, %Account{} = account} = Accounts.create_account(@valid_attrs)
    end

    test "create_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_account(@invalid_attrs)
    end

    test "update_account/2 with valid data updates the account" do
      account = account_fixture()
      assert {:ok, %Account{} = account} = Accounts.update_account(account, @update_attrs)
    end

    test "update_account/2 with invalid data returns error changeset" do
      account = account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_account(account, @invalid_attrs)
      assert account == Accounts.get_account!(account.id)
    end

    test "delete_account/1 deletes the account" do
      account = account_fixture()
      assert {:ok, %Account{}} = Accounts.delete_account(account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_account!(account.id) end
    end

    test "change_account/1 returns a account changeset" do
      account = account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_account(account)
    end
  end

  describe "token_histories" do
    alias Wynix.Accounts.TokenHistory

    @valid_attrs %{order_code: "some order_code", token_type: "some token_type"}
    @update_attrs %{order_code: "some updated order_code", token_type: "some updated token_type"}
    @invalid_attrs %{order_code: nil, token_type: nil}

    def token_history_fixture(attrs \\ %{}) do
      {:ok, token_history} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_token_history()

      token_history
    end

    test "list_token_histories/0 returns all token_histories" do
      token_history = token_history_fixture()
      assert Accounts.list_token_histories() == [token_history]
    end

    test "get_token_history!/1 returns the token_history with given id" do
      token_history = token_history_fixture()
      assert Accounts.get_token_history!(token_history.id) == token_history
    end

    test "create_token_history/1 with valid data creates a token_history" do
      assert {:ok, %TokenHistory{} = token_history} = Accounts.create_token_history(@valid_attrs)
      assert token_history.order_code == "some order_code"
      assert token_history.token_type == "some token_type"
    end

    test "create_token_history/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_token_history(@invalid_attrs)
    end

    test "update_token_history/2 with valid data updates the token_history" do
      token_history = token_history_fixture()
      assert {:ok, %TokenHistory{} = token_history} = Accounts.update_token_history(token_history, @update_attrs)
      assert token_history.order_code == "some updated order_code"
      assert token_history.token_type == "some updated token_type"
    end

    test "update_token_history/2 with invalid data returns error changeset" do
      token_history = token_history_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_token_history(token_history, @invalid_attrs)
      assert token_history == Accounts.get_token_history!(token_history.id)
    end

    test "delete_token_history/1 deletes the token_history" do
      token_history = token_history_fixture()
      assert {:ok, %TokenHistory{}} = Accounts.delete_token_history(token_history)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_token_history!(token_history.id) end
    end

    test "change_token_history/1 returns a token_history changeset" do
      token_history = token_history_fixture()
      assert %Ecto.Changeset{} = Accounts.change_token_history(token_history)
    end
  end
end
