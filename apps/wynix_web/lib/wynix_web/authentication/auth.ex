defmodule WynixWeb.Authentication.Auth do
    @moduledoc """
        Provides functionalities for authenticating a given user
    """
    alias Wynix.Accounts
    alias WynixWeb.Authentication.Guardian

    @doc """
        authenitcate returns {:ok, %User{}} if the user if found and the credentials are correct
        Retruns {:error, "invalid password"} if the user is found and the credentials are wrong
        Returns {:error, "invalid user-identifier"} if the user is not found in the db
    """
    @spec authenticate(user :: Accounts.User, password :: String.t) :: {:ok, Accounts.User} | {:error, String.t} | {:error, String.t}
    def authenticate(user, password), do: user |> Argon2.check_pass(password)


    # function for returning a token
    def create_token(user) do
        # create a session for the iser
        # encode and sign the user and create a new session for the user
        with {:ok, jwt, _claims} <- Guardian.encode_and_sign(user), {:ok, _} <- user |> Ecto.build_assoc(:sessions, %{token: jwt}) |> Accounts.create_session() do
            # return the token
            {:ok, jwt}
        end # end of with for encoding and signing the token
    end # end of create token

end # end of PractiseWeb.Authentication.Auth module
