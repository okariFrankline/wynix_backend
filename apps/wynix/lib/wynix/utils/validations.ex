defmodule Wynix.Utils.Validations do
  @moduledoc """
    Provides validation functions for the wynix app
  """
  import Ecto.Changeset

  @doc false
  def validate_email_format(%Ecto.Changeset{valid?: true, changes: %{email: email}} = changeset) do
    # check the email address against the regular expresion for the email address
    case Regex.run(~r/^[\w.!#$%&’*+\-\/=?\^`{|}~]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*$/i, email) do
        # email is invalid
        nil ->
          # add an error to the changeset
          changeset
          # add the error to the changeset
          |> add_error(:email, "The email: #{email}, has an invalid format.")

        # the email is valid.
        list when list !== [] ->
            # return the changeset
            changeset
    end # end of the case for Regex.run
  end # end of of the validate_email formati if the changeset os valid
  def validate_email_format(changeset), do: changeset

  @doc false
  def validate_phone_format(phone_number, country) do
    # craete the phone number using ExPhoneNUmber
    {:ok, phone_number} = ExPhoneNumber.parse(phone_number, country)
    # check if the phone number is valid
    if ExPhoneNumber.is_valid_number?(phone_number) do
      # internationalize the number and put it in the changese
      phone_number = ExPhoneNumber.format(phone_number, :international)
      # return an okay tuple with the international number
      {:ok, phone_number}
    else # the phone number is invalid
      # add an error message
      {:error, :not_valid}
    end # end of checking the validity of the phone number
  end # end of validate phone number/2

end # end of the validations module
