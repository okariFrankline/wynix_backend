defmodule Wynix.Accounts.Account do
  @moduledoc """
    Holds critical information about the current user's account details
    Details include banking details, mobile payment preferences, and other information
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Wynix.Accounts.User
  alias Wynix.Utils.{Validations, Generator}

  @mpesa_countries ["Kenya", "Tanzania", "Uganda", "Rwanda", "South Sudan", "Mozambique", "Ghana", "Egypt"]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field :account_code, :string
    # account type
    field :account_type, :string
    # is suspended
    field :is_suspended, :boolean, default: false
    # full name of the name
    field :account_name, :string
    # mpesa phone number
    field :mpesa_number, :string
    # paypal account
    field :paypal, :string
    # payoneer
    field :payoneer, :string
    # email addresses
    field :emails, {:array, :string}
    field :email, :string, virtual: true
    # phone number
    field :phones, {:array, :string}
    field :phone, :string, virtual: true
    # token field
    field :bid_tokens, :integer, default: 10
    # publish tokens
    field :publish_tokens, :integer, default: 5
    # banking information
    field :bank_name, :string
    field :bank_branch, :string
    field :account_number, :string
    # location information
    field :country, :string
    field :city, :string
    field :physical_address, :string


    # relationships
    belongs_to :user, User
    has_many :token_histories, Wynix.Accounts.TokenHistory

    timestamps()
  end # end of the schema definition

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [
      :mpesa_number,
      :paypal,
      :payoneer,
      :emails,
      :phones,
      :account_name,
      :bid_tokens,
      :publish_tokens,
      :account_type,
      :account_code,
      :account_number,
      :bank_branch,
      :bank_name
    ])
  end

  @doc false
  def creation_changeser(account, attrs) do
    changeset(account, attrs)
    # add the account code
    |> add_account_code()
  end

  @doc false
  def banking_changeset(account, attrs) do
    changeset(account, attrs)
    # ensure all the fields are given
    |> validate_required([
      :bank_name,
      :bank_branch,
      :account_number
    ])
  end # end of the banking changeset

  @doc false
  def location_changeset(account, attrs) do
    changeset(account, attrs)
    # validate the required fields
    |> validate_required([
      :country,
      :city
    ])
  end # end of location changeset

  @doc false
  def add_email_changeset(account, attrs) do
    changeset(account, attrs)
    |> cast(attrs, [
      :email
    ])
    # ensure it is given
    |> validate_required([
      :email
    ])
    # validate the email format
    |> Validations.validate_email_format()
    # ensure the email is not already in the user's email list
    |> validate_email_not_repeated()
    # add the email to the list of emails
    |> add_to_email_list()
  end # end of the add_email_changeset/2

  @doc false
  def add_payoneer_changeset(account, attrs) do
    changeset(account, attrs)
    |> cast(attrs, [
      :payoneer
    ])
    # ensure the payoneer is given
    |> validate_required([
      :payoneer
    ])
    # ensure the payoneer is unique
    |> unique_constraint(:payoneer, [
      message: "The payoneer account #{attrs["payoneer"]} has been taken."
    ])
  end # end of add_payoneer-changeset/2

  @doc false
  def add_paypal_changeset(account, attrs) do
    changeset(account, attrs)
    |> cast(attrs, [
      :paypal
    ])
    # ensure the paypal is given
    |> validate_required([
      :paypal
    ])
    # ensure the paypal is unique
    |> unique_constraint(:paypal, [
      message: "The paypal account #{attrs["paypal"]} has been taken."
    ])
  end # end of the add_paypal_account/2

  @doc false
  def add_mpesa_changeset(account, attrs) do
    changeset(account, attrs)
    |> cast(attrs, [
      :mpesa_number
    ])
    # ensure the number is given
    |> validate_required([
      :mpesa_number
    ])
    # validate the phone number
    |> validate_phone_format()
    # ensure the phone number is unique
    |> unique_constraint(:mpesa_number, [
      message: "Failed! The Mpesa phone number #{attrs["mpesa_number"]} is already taken."
    ])
  end # end of the add_mpesa_changeset

  @doc false
  def add_phone_changeset(account, attrs) do
    changeset(account, attrs)
    |> cast(attrs, [
      :phone
    ])
    # ensure the email is given
    |> validate_required([
      :phone
    ])
    # validate the phone format
    |> validate_phone_format()
    # ensure the phone number is not repeated
    |> validate_phone_not_repeated()
    # add the phone number to the current list of phone numbers
    |> add_to_phone_list()
  end # end of add_email_changeset/2


  # Validate not already added checks to ensure that the email being added is not already
  # in the list of emails.
  defp validate_email_not_repeated(%Ecto.Changeset{valid?: true, changes: %{email: email}, data: %__MODULE__{emails: emails}} = changeset) do
    if email in emails do
      # add error to the changeset
      changeset |> add_error(:email, "Failed! The email #{email} is already registered for your account.")
    else
      # return the changeset as is
      changeset
    end # end of if
  end # end of validate_not_already_added/2 when the changeset is valid
  defp validate_email_not_repeated(changeset), do: changeset

  # Validate phone not repeated checks to ensure that the phone number being added is not already
  # in the list of phones.
  defp validate_phone_not_repeated(%Ecto.Changeset{valid?: true, changes: %{phone: phone}, data: %__MODULE__{phones: phones}} = changeset) do
    if phone in phones do
      # add error to the changeset
      changeset |> add_error(:phone, "Failed! The phone number #{phone} is already registered for your account.")
    else
      # return the changeset as is
      changeset
    end # end of if
  end # end of validate_phone_not_repeated/2 when the changeset is valid
  defp validate_phone_not_repeated(changeset), do: changeset

  # validate phone format checks to ensure the phone number is valid for the country in which it is entered
  defp validate_phone_format(%Ecto.Changeset{valid?: true, changes: %{mpesa_number: number}, data: %__MODULE__{country: country}} = changeset) do
    # check to ensure the country is in mpesa_countries
    if country in @mpesa_countries do
      # validate the number for the country given by the user
      case Validations.validate_phone_format(number, country) do
        # the phone number is valid
        {:ok, phone_number} ->
          # put the number to the changeset
          changeset |> put_change(:mpesa_number, phone_number)
        # phone number is invalid for the given country
        {:error, :invalid} ->
          # add error indicating invalid format
          changeset |> add_error(:mpesa_number, "Failed! The phone number #{number} is invalid for the country #{country}")
      end # end of case for validation the phone number
    else
      # add error indicating the country does not use mpesa
      changeset |> add_error(:mpesa_number, "Failed! Mpesa services are not available in your country.")
    end # end of checking if country in mpesa countries
  end # end of the validate_phone_format/1
  defp validate_phone_format(changeset), do: changeset

  # add to phone list
  defp add_to_phone_list(%Ecto.Changeset{valid?: true, changes: %{phone: phone}, data: %__MODULE__{phones: phones}} = changeset) do
    # add the list of current list of emails
    changeset |> put_change(:phones, [phone | phones])
  end # end of add to phone list when the changeset is valid
  defp add_to_phone_list(changeset), do: changeset

  # add to emailemail
  defp add_to_email_list(%Ecto.Changeset{valid?: true, changes: %{email: email}, data: %__MODULE__{emails: emails}} = changeset) do
    # add the list of current list of emails
    changeset |> put_change(:emails, [email | emails])
  end # end of add to phone list when the changeset is valid
  defp add_to_email_list(changeset), do: changeset

  defp add_account_code(%Ecto.Changeset{valid?: true} = changeset), do: changeset |> put_change(:account_code, Generator.generate())
  defp add_account_code(changeset), do: changeset

end # end of the Account's module
