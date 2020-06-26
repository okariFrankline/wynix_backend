defmodule WynixWeb.UserController do
  use WynixWeb, :controller

  alias Wynix.Accounts
  alias Wynix.Accounts.User
  alias Wynix

  action_fallback WynixWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    # get the account type
    account_type = case Map.fetch!(user_params, "account_type") do
      # Professional Account
      "Practise Account" -> :practise
      # client account
      _ -> :client
    end # end of checking the account type

    # create a new user
    with {:ok, account} <- Wynix.create_user(account_type, user_params) do
      conn
      |> put_status(:created)
      |> render("account.json", result: account)
    end # end of with for creating a new order

  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
