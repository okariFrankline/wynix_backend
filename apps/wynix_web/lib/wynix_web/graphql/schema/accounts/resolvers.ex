defmodule WynixWeb.Schema.Accounts.Resolver do
  @moduledoc """
    Defines resolver functions for the Account types
  """
  alias Wynix
  alias Wynix.{Accounts, Repo}
  alias WynixWeb.Authentication.Auth

  @doc false
  def get_account(_parent, args, _resolution) do
    # return the account
    account = Accounts.get_account!(args.id)
    # return the the account
    {:ok, %{account: account}}
  rescue
    Ecto.NoResultsError ->
      # ERRORS
      errors = [
        %{
          key: "Unavailable",
          message: "Account not found."
        }
      ]
      # return value
      {:ok, %{errors: errors}}
  end # end of get_account/3

  @doc false
  def my_account(_parent, _args, %{context: %{current_account: account}}), do: {:ok, %{account: account}}

  @doc false
  def create_practise_account(_parent, %{input: account_input}, _resolution) do
    # create the account
    with {:ok, account} <- Wynix.create_user(:practise, account_input) do
      {:ok, %{account: account}}
    end # end of account result
  end # end of create_account/3

   @doc false
  def create_client_account(_parent, %{input: account_input}, _resolution) do
    # create the account
    with {:ok, account} <- Wynix.create_user(:client, account_input) do
      {:ok, %{account: account}}
    end # end of account result
  end # end of create_account/3

  @doc false
  def update_banking(_parent, %{input: banking_input}, %{context: %{current_account: account}}) do
    with {:ok, account} <- Accounts.update_account_banking(account, banking_input) do
      {:ok, %{account: account}}
    end # end of with
  end # end of update_banking information

  @doc false
  def update_location(_parent, %{input: location_input}, %{context: %{current_account: account}}) do
    with {:ok, account} <- Accounts.update_account_location(account, location_input) do
      {:ok, %{account: account}}
    end # end of with
  end # end of the update_location/3

  @doc false
  def update_paypal(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, account} <- Accounts.update_account_paypal(account, %{paypal: args.paypal}) do
      {:ok, %{account: account}}
    end # end of with
  end # end of update_paypal

  @doc false
  def update_payoneer(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, account} <- Accounts.update_account_payoneer(account, %{payoneer: args.payoneer}) do
      {:ok, %{account: account}}
    end # end of with
  end # end of update_payoneer/3

  @doc false
  def update_mpesa(_parent, args, %{context: %{current_account: account}}) do
    with {:ok, account} <- Accounts.update_account_mpesa(account, %{mpesa_number: args.mpesa}) do
      {:ok, %{account: account}}
    end # end of with
  end # end of update_mpesa

  @doc false
  def update_user_auth_email(_parent, %{input: auth_input}, %{context: %{currrent_account: account}}) do
    # preload the auth user for the account
    auth_user = Repo.preload(account, :user)
    # update the auth email
    with {:ok, user} <- Accounts.update_user_auth_email(auth_user, auth_input), account do
      # update the email in the account
      emails = List.delete(account.emails, auth_user.email)
      # add the new email to the list of current emails
      emails = [user.auth_email | emails]
      # update the acconunt in the db
      account = account
      # put the new emails in the account changeset
      |> Ecto.Changeset.change(%{
        emails: emails
      })
      # update the account
      |> Repo.update!()
      # return the account
      {:ok, %{account: account}}
    end # end of with
  end # end of update_auth_email/3

  @doc false
  def update_user_auth_password(_parent, %{input: auth_password_input}, %{context: %{current_account: account}}) do
    # preload the user
    user = Repo.preload(account, :user)
    # update the password
    with {:ok, _user} <- Accounts.update_user_auth_password(user, auth_password_input) do
      {:ok, %{account: account}}
    end # end of with
  end # end of update_auth_password/3

  @doc false
  def create_session(_parent, %{input: %{auth_email: email, password: password}}, _resolution) do
    # get the user with the given email
    user = Repo.get_by!(Accounts.User, auth_email: email)
    # authenticate the user
    with {:ok, user} <- Auth.authenticate(user, password), {:ok, token} <- Auth.create_token(user) do
      # return the token
      {:ok, %{token: token}}
    else
      {:error, _} ->
        errors = [%{
          key: "Wrong Credentials",
          message: "Wrong Account Credentials."
        }]
        # return
        {:ok, %{errors: errors}}
    end # end of authenticating and creating a token
  rescue
    Ecto.NoResultsError ->
      # errors
      errors = [%{
        key: "Not Found",
        message: "Account with email #{email} not found."
      }]
      # return the response
      {:ok, %{errors: errors}}
  end # end of create_session


end # end of the accounts resolvers
