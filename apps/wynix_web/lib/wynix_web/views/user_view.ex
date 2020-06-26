defmodule WynixWeb.UserView do
  use WynixWeb, :view
  alias WynixWeb.UserView

  def render("account.json", %{account: account}) do
    %{data: %{
      account: %{
        account_id: account.id,
        account_name: account.account_name,
        account_emails: account.emails,
        account_phones: account.phones,
        
      }
    }}
  end # end render for account.json

  def render("user_created.json", %{user: user, account: account}) do
    # return the account and the user details
    %{data: %{
      account: render_one(account, UserView, "account.json"),
      user: render_one(account, UserView, "user.json")
    }}
  end # end of render function for when a user has been created

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,

    }
  end
end
