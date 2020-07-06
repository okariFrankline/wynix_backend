defmodule Wynix.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wynix.Utils.Validations
  alias Wynix.Accounts.{Account, Session}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :auth_email, :string
    # indeicates whether the user is active or not
    field :is_active, :boolean, default: false
    # hshed password that is stored in the db
    field :password_hash, :string
    # holds the new password during user creation and password changing processes
    field :password, :string, virtual: true
    # holds the current password during the password changing process
    field :current_password, :string, virtual: true
    field :username, :string
    # relationships
    has_one :account, Account
    # has many sessions that are running
    has_many :sessions, Session

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :username,
      :auth_email,
      :password_hash,
      :is_active,
    ])
  end # end of the changeset

  @spec creation_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def creation_changeset(user, attrs) do
    changeset(user, attrs)
    |> cast(attrs, [
      :password
    ])
    # ensure the fields are given
    |> validate_required([
      :auth_email,
      :password
    ])
    # validate the format of the email
    |> Validations.validate_email_format()
    # validate the the length of the password
    |> validate_length(:password, [
      min_length: 8
    ])
    # insert the username to the changeset
    |> insert_username()
    # hash the password
    |> hash_password()
    # unique constraint on the email address
    |> unique_constraint(:auth_email, message: "The email address #{attrs["auth_email"]} is already taken.")
  end # end of the creation changeset

  @spec email_change_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def email_change_changeset(user, attrs) do
    changeset(user, attrs)
    |> cast(attrs, [
      :current_password
    ])
    # ensure email is given
    |> validate_required([
      :auth_email,
      :current_password
    ])
    # validate the email format
    |> Validations.validate_email_format()
    # validate the current password
    |> validate_current_password()
    # insert the new username
    |> insert_username()
    # ensure the new email is not similar to the current email in use
    |> validate_new_not_equal_to_current_email()
    # ensure the emailis unique
    |> unique_constraint(:auth_email,
      [message: "Failed. The email address #{attrs["emal"]} has been taken."]
    )
  end # end of the email change changeset

  @spec password_change_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: any
  @doc false
  def password_change_changeset(user, attrs) do
    changeset(user, attrs)
    #cast the password
    |> cast(attrs, [
      :password,
      :current_password
    ])
    # ensure the new password is given
    |> validate_required([
      :password,
      :current_password
    ])
    # ensure the password has a minimum of 8 characters
    |> validate_length(:password, [
      min_length: 8,
      max_length: 100
    ])
    # validate current password
    |> validate_current_password()
    # validate new and current password in use are not similar
    |> validate_new_not_equal_to_current_password()
  end # end of the password_change_changeset/2


  @doc false
  defp insert_username(%Ecto.Changeset{valid?: true, changes: %{auth_email: email}} = changeset) do
    # get the username from the email
    [_email, username, _domain] = Regex.run(~r/(\w+)@([\w.]+)/, email)
    # add the username to the changeset
    changeset |> put_change(:username, username)
  end # enf of insert username/1
  defp insert_username(changeset), do: changeset

  # Hash password hashes the password entered
  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    changeset
    # put the hashed assword
    |> change(Argon2.add_hash(password))
  end # end of the hash_password/1 when the changeset is valid
  defp hash_password(changeset), do: changeset


  # Validate current password checks to ensure that the current password in user is similar to
  # the password entered under current password field
  defp validate_current_password(%Ecto.Changeset{valid?: true, changes: %{current_password: password}, data: %__MODULE__{password_hash: hash}} = changeset) do
    if Argon2.verify_pass(hash, password) do
      # return the changest as is
      changeset
    else
      # put an error on the current password field
      changeset |> add_error(:current_password, "Failed. The current password entered does not match the is currently in use.")
    end # end checking if the password are similar
  end # end of validate_current_password/2 when the changeset is valid
  defp validate_current_password(changeset), do: changeset


  #  Valite new not equal to current email compares the new email entered and the current email in use and
  #  ensures that they are not similar
  defp validate_new_not_equal_to_current_email(%Ecto.Changeset{valid?: true, changes: %{auth_email: email}, data: %__MODULE__{auth_email: current_email}} = changeset)do
    if email === current_email do
      # add error on the password
      changeset |> add_error(:auth_email, "Failed. The new email entered and the current email in use are similar.")
    else
      # return the changeset
      changeset
    end # end of checking the passwords are simialr
  end # end of validate_new_not_equal_to_current_email/1 when the changeset is not valid
  defp validate_new_not_equal_to_current_email(changeset), do: changeset


  #  Valite new not equal to current password compares the new password entered and the current password in use and
  #  ensures that they are not similar
  defp validate_new_not_equal_to_current_password(%Ecto.Changeset{valid?: true, changes: %{password: password}, data: %__MODULE__{password_hash: hash}} = changeset)do
    if Argon2.verify_pass(hash, password) do
      # add error on the password
      changeset |> add_error(:password, "Failed. The new password entered and the current password in use are similar.")
    else
      # return the changeset
      changeset
    end # end of checking the passwords are simialr
  end # end of validate_new_not_equal_to_current_password/1 when the changeset is not valid
  defp validate_new_not_equal_to_current_password(changeset), do: changeset

end # end of the user module
