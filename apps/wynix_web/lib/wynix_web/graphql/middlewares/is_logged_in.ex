defmodule WynixWeb.Schema.Middlewares.IsLoggedIn do
    @moduledoc """
        Defines a middleware that ensures that a user is already loggen in
    """
    @behaviour Absinthe.Middleware
    alias Wynix.Accounts.{Account}

    # call function
    def call(resolution, _opts) do
        # ensure that the context is on in the resolution
        with %{context: %{current_account: account}} <- resolution do
            # chek  the value of the current user
            case account do
                # the user is logged in
                %Account{} = _account ->
                    # the user is in the context.
                    # return the resolution
                    resolution
                # the user is not logged in
                _ ->
                    # add Not logged in error to the resolution
                    resolution
                    |> Absinthe.Resolution.put_result({:error, "Not Logged in. Login in to continue"})
            end # end of caese for checking the user
        end # end of the with for checking whether the current user is in the context
    end # end of the call function

end # end of the Ejob.Schema.Middlewares.Authorized module
