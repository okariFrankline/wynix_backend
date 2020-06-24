defmodule Wynix do
  @moduledoc """
  Wynix keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  alias Wynix.{Accounts, Skills}

  @doc """
    Create user creates a user together with his/her account and practise depending on the account type
  """
  def create_user(:practise, attrs) do
    with {:ok, user} <- Accounts.create_user(attrs) do
      # create an account for the user
      {:ok, _account} = user |> Ecto.build_assoc(attrs) |> Accounts.create_account()
      # create the practise
      {:ok, _pratise} = user |> Ecto.build_assoc(attrs) |>Skills.create_practise()
      # preload the practise and the account
      {:ok, Accounts.preload_user(:practise, user)}

    else
      {:error, _changeset} = changeset ->
        # return the changeset
        changeset
    end # end of creating a user
  end # end fo create_user/2 for practise

  def create_user(:client, attrs) do
    with {:ok, user} <- Accounts.create_user(attrs) do
      # create an account for the user
      {:ok, _account} = user |> Ecto.build_assoc(attrs) |> Accounts.create_account()
      # preload the practise and the account
      {:ok, Accounts.preload_user(:client, user)}

    else
      {:error, _changeset} = changeset ->
        # return the changeset
        changeset
    end # end of creating a user
  end # end of create_user for the client/2

end # function for creating a user
