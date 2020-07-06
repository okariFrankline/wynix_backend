
defmodule WynixWeb.Authentication.Guardian do
  @moduledoc """
      Implements the Guardian behaviour which will be used for authentication
  """
  use Guardian, otp_app: :wynix_web
  # alias the practise accounts module
  # alias Wynix.Accounts
  alias Wynix.Accounts.{User}
  alias Wynix.{Repo, Accounts}

  # subject from token
  @spec subject_for_token(%User{}, map()) :: {:ok, String.t()}
  def subject_for_token(user, _claims) do
      {:ok, to_string(user.id)}
  end # end of subject from token

  # resource  from token.
  @spec resource_from_claims(claims :: map()) :: {:ok, %User{}}
  def resource_from_claims(%{"sub" => id} = _claims) do
      # get the user
      account = Accounts.get_user!(id) |> Repo.preload([:account])
      # return the user
      {:ok, account}
  end # end of csurce from token

end # end of the PractiseWeb.Authentication.Guadian module
