defmodule WynixWeb.Schema do
  use Absinthe.Schema
  alias __MODULE__.Middlewares
  import_types Absinthe.Type.Custom

  import_types __MODULE__.Types.Accounts
  import_types __MODULE__.Types.Bids
  import_types __MODULE__.Types.Orders
  import_types __MODULE__.Types.Practise

  # middleware function that ensures that the changeset error is applied to all mutation objects
    # after resolution has been completed
    def middleware(middleware, field, object) do
        # add the changeset middle ware after the already stated middlewares
        middleware
        # apply authorization middleware
        |> apply(:errors, field, object)
    end # end of the middleware function

    # add the chageset midware
    defp apply(middleware, :errors, _field, %{identifier: :mutation}) do
        middleware ++ [Middlewares.ChangesetError]
    end # end of applying middle for error handling

    # default middleware application of the object identifief is not mutation
    defp apply(middleware, _, _field, _object) do
        middleware
    end # end of returning middleware as is

  # root query
  query do
    # import the accounts mutations
    import_fields :account_queries
    # import practise mutations
    import_fields :practise_queries
    # import the orders mutations
    import_fields :order_queries
    # import the bid mutations
    #import_fields :bid_queries
  end # end of the root query

  # root mutation
  mutation do
    # import the accounts mutations
    import_fields :account_mutations
    # import practise mutations
    import_fields :practise_mutations
    # import the orders mutations
    import_fields :orders_mutations
    # import the bid mutations
    import_fields :bid_mutations
  end # end of the root mutation

end # end of the schema definition for the wynix application
