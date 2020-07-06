defmodule Wynix.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias Wynix.Repo

  alias Wynix.Accounts.{User, Session}

  # function for creating a new session
  def create_session(attrs \\ %{}) do
    %Session{}
    |> Session.changeset(attrs)
    |> Repo.insert()
  end

  @doc false
  def preload_user(:practise, %User{} = user) do
    Repo.preload(user, [
      :account,
      :practise
    ])
  end # end preload_user/2 for a practise account_type

  @doc false
  def preload_user(:client, %User{} = user) do
    Repo.preload(user, :client)
  end # end of preload_user for a client account

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's email address.

  ## Examples

      iex> update_user_email(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_email(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_email(%User{} = user, attrs) do
    user
    |> User.email_change_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a user's password.

  ## Examples

      iex> update_user_password(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user_password(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_password(%User{} = user, attrs) do
    user
    |> User.password_change_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  alias Wynix.Accounts.Account

  @doc """
  Returns the list of accounts.

  ## Examples

      iex> list_accounts()
      [%Account{}, ...]

  """
  def list_accounts do
    Repo.all(Account)
  end

  @doc """
  Gets a single account.

  Raises `Ecto.NoResultsError` if the Account does not exist.

  ## Examples

      iex> get_account!(123)
      %Account{}

      iex> get_account!(456)
      ** (Ecto.NoResultsError)

  """
  def get_account!(id), do: Repo.get!(Account, id)

  @doc """
  Creates a account.

  ## Examples

      iex> create_account(%{field: value})
      {:ok, %Account{}}

      iex> create_account(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_account(attrs \\ %{}) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account(%Account{} = account, attrs) do
    account
    |> Account.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account.

  ## Examples

      iex> update_account_banking(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_banking(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_banking(%Account{} = account, attrs) do
    account
    |> Account.banking_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account's location.

  ## Examples

      iex> update_account_location(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_location(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_location(%Account{} = account, attrs) do
    account
    |> Account.location_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account's location.

  ## Examples

      iex> update_account_payoneer(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_payoneer(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_payoneer(%Account{} = account, attrs) do
    account
    |> Account.add_payoneer_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account's bid tokens.

  ## Examples

      iex> update_account_bid_tokens(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_bid_tokens(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_bid_tokens(%Account{} = account, %{bid_tokens: bid_tokens} = attrs) when is_integer(bid_tokens) do
    account
    |> Ecto.Changeset.change(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account's publish tokens.

  ## Examples

      iex> update_account_publish_tokens(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_publish_tokens(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_publish_tokens(%Account{} = account, %{publish_tokens: publish_tokens} = attrs) when is_integer(publish_tokens) do
    account
    |> Ecto.Changeset.change(attrs)
    |> Repo.update()
  end


  @doc """
  Updates a account's paypal.

  ## Examples

      iex> update_account_paypal(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_paypal(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_paypal(%Account{} = account, attrs) do
    account
    |> Account.add_paypal_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account's mpesa.

  ## Examples

      iex> update_account_mpesa(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_mpesa(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_mpesa(%Account{} = account, attrs) do
    account
    |> Account.add_mpesa_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account's email.

  ## Examples

      iex> update_account_email(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_email(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_email(%Account{} = account, attrs) do
    account
    |> Account.add_email_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a account's phone.

  ## Examples

      iex> update_account_phone(account, %{field: new_value})
      {:ok, %Account{}}

      iex> update_account_phone(account, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_account_phone(%Account{} = account, attrs) do
    account
    |> Account.add_phone_changeset(attrs)
    |> Repo.update()
  end



  @doc """
  Deletes a account.

  ## Examples

      iex> delete_account(account)
      {:ok, %Account{}}

      iex> delete_account(account)
      {:error, %Ecto.Changeset{}}

  """
  def delete_account(%Account{} = account) do
    Repo.delete(account)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.

  ## Examples

      iex> change_account(account)
      %Ecto.Changeset{data: %Account{}}

  """
  def change_account(%Account{} = account, attrs \\ %{}) do
    Account.changeset(account, attrs)
  end

  alias Wynix.Accounts.TokenHistory

  @doc """
  Returns the list of token_histories.

  ## Examples

      iex> list_token_histories()
      [%TokenHistory{}, ...]

  """
  def list_token_histories do
    Repo.all(TokenHistory)
  end

  @doc """
  Gets a single token_history.

  Raises `Ecto.NoResultsError` if the Token history does not exist.

  ## Examples

      iex> get_token_history!(123)
      %TokenHistory{}

      iex> get_token_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_token_history!(id), do: Repo.get!(TokenHistory, id)

  @doc """
  Creates a token_history.

  ## Examples

      iex> create_token_history(%{field: value})
      {:ok, %TokenHistory{}}

      iex> create_token_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token_history(attrs \\ %{}) do
    %TokenHistory{}
    |> TokenHistory.changeset(attrs)
    |> Repo.insert()
  end


  @doc """
  Deletes a token_history.

  ## Examples

      iex> delete_token_history(token_history)
      {:ok, %TokenHistory{}}

      iex> delete_token_history(token_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token_history(%TokenHistory{} = token_history) do
    Repo.delete(token_history)
  end

end
