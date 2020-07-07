defmodule Wynix.Accounts.Session do
    @moduledoc """
      Holds session information about a given account user
    """
    use Ecto.Schema
    import Ecto.Changeset

    @primary_key {:id, :binary_id, autogenerate: true}
    @foreign_key_type :binary_id
    schema "sessions" do
      field :token, :string
      # belongs to user
      belongs_to :user, Wynix.Accounts.User
    end # end of the schema function

    @spec changeset(
            {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
            :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
          ) :: Ecto.Changeset.t()
    def changeset(session, attrs) do
      session
      # cast the change
      |> cast(attrs, [
        :token
      ])
      # validate the required fields
      |> validate_required([
        :token,
        :user_id
      ])
    end # end of the changeset/2
end # end of sessions
