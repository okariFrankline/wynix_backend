defmodule WynixWeb.Plugs.UserContext do
  @moduledoc """
    used to insert the user to the context.
  """
  @behaviour Plug
  # import the plug conn
  import Plug.Conn
  # alias the user struct
  alias Wynix.Accounts.{Session, Account}
  # imprt where
  import Ecto.Query, only: [where: 2]
  # alias Repo
  alias Wynix.Repo

  def init(opts), do: opts

  # define the call function
  def call(conn, _opts) do
    context = build_context(conn)
    # add teh context to absinthe
    Absinthe.Plug.put_options(conn, context: context)
  end # end of call

  @doc """
  Return the current user context based on the authorization header
  """
  def build_context(conn) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
        # get the current user
        {:ok, %Account{} = current_account} <- authorize(token) do
          # return a map of the current user
          IO.inspect current_account
          %{current_account: current_account}

      else
        # return an empty map
        _ -> %{}
    end # end of with
  end # end of build contxt

  defp authorize(token) do
    Session
    # filter only where the token is required
    |> where(token: ^token)
    # get one result from the dp
    |> Repo.one()
    # check if ther user exists or not
    |> case do
      nil -> {:ok, "Invalid Authorization token"}
      # the user exist
      %Session{} = session ->
        # get the account
        account = session |> Repo.preload([:user]) |> Repo.preload([:account])
        # return the account
        {:ok, account}
    end # end of cond
  end # end of the authorize function

end # end of module
