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

end # end of the validations module
