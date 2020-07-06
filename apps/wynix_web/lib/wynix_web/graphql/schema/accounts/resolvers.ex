defmodule WynixWeb.Schema.Accounts.Resolver do
  @moduledoc """
    Defines resolver functions for the Account types
  """
  alias Wynix
  alias Wynix.{Accounts}

  @doc false
  def get_account(_parent, args, _resolution) do
    # return the account
    account = Accounts.get_account!(args.id)
    # return the the account
    {:ok, account}
  rescue
    Ecto.NoResultsError ->
      # ERRORS
      errors = [
        %{
          key: "Not Found",
          message: "Account Not found"
        }
      ]
      # return value
      {:ok, %{errors: errors}}
  end # end of get_account/3

  @doc false
  def create_account(_parent, %{input: account_input}, _resolution) do
    # get the type of account being created.
    account_type = case Map.fetch!(account_input, "account_type") do
      # account is a practise account
      "Practise Account" -> :practise
      # account is a client account
      "Client Account" -> :client
    end # end of case for checking the account type
    # create the account
    with {:ok, _account} = result <- Wynix.create_user(account_type, account_input) do
      result
    end # end of account result
  end # end of create_account/3

  @doc false
  def update_banking(_parent, %{input: banking_input}, %{context: %{current_account: account}}) do
    with {:ok, _account} = result <- Accounts.update_account_banking(account, banking_input) do
      result
    end # end of with
  end # end of update_banking information

  @doc false
  def update_location(_parent, %{input: location_input}, %{context: %{current_account: account}}) do
    with {:ok, _account} = result <- Accounts.update_account_location(account, location_input) do
      result
    end # end of with
  end # end of the update_location/3

  @doc false
  def update_paypal(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, _account} = result <- Accounts.update_account_paypal(account, %{paypal: args.paypal}) do
      result
    end # end of with
  end # end of update_paypal

  @doc false
  def update_payoneer(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, _account} = result <- Accounts.update_account_payoneer(account, %{payoneer: args.payoneer}) do
      result
    end # end of with
  end # end of update_payoneer/3

  @doc false
  def update_mpesa(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, _account} = result <- Accounts.update_account_mpesa(account, %{mpesa: args.mpesa}) do
      result
    end # end of with
  end # end of update_mpesa

  @doc false
  def update_auth_email(_parent, %{input: auth_input}, %{context: %{currrent_account: account}}) do
    # preload the auth user for the account
    auth_user = Repo.prelaod(account, :user)
    # update the auth email
    with {:ok, user} <- Accounts.update_user_auth_email(auth_user, auth_input), account <- Repo.preload(user, :account) do
      # return the account
      {:ok, account}
    end # end of with
  end # end of update_auth_email/3

  @doc false
  def update_auth_password(_parent, %{input: auth_password_input}, %{context: %{current_account: account}}) do
    # preload the user
    user = Repo.preload(account, :user)
    # update the password
    with {:ok, user} <- Accounts.update_auth_password(user, auth_password_input), account <- Rep.preload(user, :account) do
      {:ok, account}
    end # end of with
  end # end of update_auth_password/3


end # end of the accounts resolvers
