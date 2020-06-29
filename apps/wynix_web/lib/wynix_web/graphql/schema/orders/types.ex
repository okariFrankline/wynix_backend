defmodule WynixWeb.Schema.Types.Orders do
  @moduledoc """
    Defines the graphql schema types for the Orders
  """
  use Absinthe.Schema.Notation

  # account
  object :account do

  end # describes the account of a given user

  # account creation input
  input_object :account_creation do

  end # end of input object for the account

  #queries
  object :account_queries do

  end # end of the account queries

  # mutations
  object :account_mutations do

  end # end of the account mutations


end # end of the Accounts types
