defmodule WynixWeb.Schema.Types.Accounts do
  @moduledoc """
    Defines the graphql schema types for the Orders
  """
  use Absinthe.Schema.Notation
  alias WynixWeb.Schema.Accounts.Resolver
  # alias the isLoggedin middleware
  alias WynixWeb.Schema.Middlewares.IsLoggedIn

  # account
  object :account do
    field :id, non_null(:id)
    field :account_code, non_null(:string)
    # account type
    field :account_type, non_null(:string)
    # is suspended
    field :is_suspended, non_null(:boolean)
    # full name of the name
    field :account_holder, non_null(:string)

    # payment information
    field :mpesa_number, :string
    field :paypal, :string
    field :payoneer, :string

    # contact infromation
    field :emails, non_null(list_of(:string))
    field :phones, non_null(list_of(:string))

    # tokens
    field :bid_tokens, non_null(:integer)
    field :publish_tokens, non_null(:integer)

    # baking information
    field :bank_name, :string
    field :bank_branch, :string
    field :account_number, :string

    # location information
    field :country, :string
    field :city, :string
    field :physical_address, :string
  end # describes the account of a given user

  # error
  object :account_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end # end of account error

  # account result
  object :account_result do
    field :account, :account
    # errors
    field :errors, list_of(:account_error)
  end # end of account result

  # session result
  object :session_result do
    field :token, :string
    field :errors, list_of(:account_error)
  end # end of session result

  # account creation input
  input_object :practise_account_input do
    field :auth_email, non_null(:string)
    field :password, non_null(:string)
    field :account_type, (non_null(:string))
    field :practise_type, non_null(:string)
    field :practise_name, non_null(:string)
  end # end of input object for the account

  # account creation input
  input_object :client_account_input do
    field :auth_email, non_null(:string)
    field :password, non_null(:string)
    field :account_type, (non_null(:string))
  end # end of input object for the account

  # input for adding the bank account
  input_object :banking_input do
    field :bank_name, non_null(:string)
    field :bank_branch, non_null(:string)
    field :account_number, non_null(:string)
  end # end of the banking info input

  # location information
  input_object :location_input do
    field :country, non_null(:string)
    field :city, non_null(:string)
    field :physical_address, :string
  end # end of the location input

  # email auth input object
  input_object :email_auth_input do
    field :auth_email, non_null(:string)
    field :current_password, non_null(:string)
  end # end of email auth_input

  # password auth input object
  input_object :password_auth_input do
    field :current_password, non_null(:string)
    field :password, non_null(:string)
  end # end of email auth_input

  # input object for the session
  input_object :session_input do
    field :auth_email, non_null(:string)
    field :password, non_null(:string)
  end # end of the session input

  #queries
  object :account_queries do
    @desc "Get account returns the account details specified by a given id"
    field :get_account, non_null(:account_result) do
      arg :id, non_null(:id)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.get_account/3)
    end # end of get user

    @desc "Get my account returns the currently logged in user's account"
    field :get_my_account, non_null(:account_result) do

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.my_account/3)
    end# end of get_my_account
  end # end of the account queries

  # mutations
  object :account_mutations do
    @desc "Create practise account creates a practise account for a new user and return the account"
    field :create_practise_account, non_null(:account_result) do
      arg :input, non_null(:practise_account_input)

      resolve(&Resolver.create_practise_account/3)
    end # end of create practise account

    @desc "Create client account creates a client account for a new user and return the account"
    field :create_client_account, non_null(:account_result) do
      arg :input, non_null(:client_account_input)

      resolve(&Resolver.create_client_account/3)
    end # end of create practise account

    @desc "Update Location updates the location of an account and returns the account"
    field :update_location, non_null(:account_result) do
      arg :input, non_null(:location_input)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.update_location/3)
    end # end of the location field

    @desc "Update Banking updates the banking information of an account and returns the account"
    field :update_banking, non_null(:account_result) do
      arg :input, non_null(:banking_input)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.update_banking/3)
    end

    @desc "Update paypal updates the paypal account information for a user and returns the account"
    field :update_paypal, non_null(:account_result) do
      arg :paypal, non_null(:string)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.update_paypal/3)
    end # end of update_paypal

    @desc "Update payoneer updates the payoneer account information for a user and returns the account"
    field :update_payoneer, non_null(:account_result) do
      arg :payoneer, non_null(:string)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.update_payoneer/3)
    end # end of update_paypal

    @desc "Update mpesa updates the mpesa account information for a user and returns the account"
    field :update_mpesa, non_null(:account_result) do
      arg :mpesa, non_null(:string)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.update_mpesa/3)
    end # end of update_paypal

    @desc "Update auth email updates the autentication email for a given account and returns the account"
    field :update_auth_email, non_null(:account_result) do
      arg :input, non_null(:email_auth_input)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.update_user_auth_email/3)
    end # end of update_auth_email

    @desc "Updates the auth password of the current account and returns the account"
    field :update_auth_password, non_null(:account_result) do
      arg :input, non_null(:password_auth_input)

      # ensure that the user is logged in
      middleware(IsLoggedIn)
      resolve(&Resolver.update_user_auth_password/3)
    end # end of update_auth_password

    @desc "Create session logs in the user."
    field :create_session, non_null(:session_result) do
      arg :input, non_null(:session_input)

      resolve(&Resolver.create_session/3)
    end # end of create session
  end # end of the account mutations


end # end of the Accounts types
