defmodule WynixWeb.UserView do
  use WynixWeb, :view
  alias WynixWeb.UserView

  def render("account.json", %{account: account}) do
    %{data: %{
      account: %{
        id: account.id,
        code: account.account_code,
        name: account.account_name,
        emails: account.emails,
        phones: account.phones,
        paypal_account: account.paypal,
        payoneer_account: account.payoneer,
        account_type: account.account_type,
        publish_tokens: account.publish_tokens,
        bid_tokens: account.bid_tokens,
        location: render_one(account.location, UserView, "location.json"),
        banking: render_one(account.banking, UserView, "banking.json"),
        user: render_one(account.user, UserView, "user.json"),
        transactions: render_many(account.transactions, UserView, "transactions.json"),
        is_suspended: account.is_suspended
      }
    }}
  end # end render for account.json

  def render("banking.json", %{banking: banking}) do
    %{
      name: banking.bank_name,
      branch: banking.branch,
      account_number: banking.account_number
    }
  end # end of render banking.json

  def render("location.json", %{location: location}) do
    %{
      city: location.city,
      physical_address: location.physical_address,
      country: location.country
    }
  end # end of the render for location.json

  def render("index.json", %{users: users}) do
    %{data: render_many(users, UserView, "user.json")}
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      token: user.token

    }
  end
end
