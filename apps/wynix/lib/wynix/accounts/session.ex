defmodule Wynix.Accounts.Sessions do
    @moduledoc """
      Holds session information about a given account user
    """
    use Ecto.Schema

    @primary_key {:id, :binary_id, autgenerate: true}
    @foreign_key_type :binar_key
    schema do
      field :token, :string
      # belongs to user
      belongs_to :user, 
    end # end of the schema function
end # end of sessions
