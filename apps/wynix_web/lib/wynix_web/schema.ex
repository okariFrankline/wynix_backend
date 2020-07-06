defmodule WynixWeb.Schema do
  use Absinthe.Schema

  import_types Absinthe.Type.Custom

  import_types __MODULE__.Types.Accounts
  import_types __MODULE__.Types.Bids
  import_types __MODULE__.Types.Orders
  import_types __MODULE__.Types.Practise

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
