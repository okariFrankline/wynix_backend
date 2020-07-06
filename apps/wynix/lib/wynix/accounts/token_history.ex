defmodule Wynix.Accounts.TokenHistory do

  use Ecto.Schema
  import Ecto.Changeset

  alias Wynix.Utils.Generator

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "token_histories" do
    field :order_code, :string
    field :token_type, :string
    field :token_code, :string
    belongs_to :account, Wynix.Accounts.Account

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(token_history, attrs) do
    token_history
    |> cast(attrs, [
      :token_type,
      :order_code,
      :token_code
    ])
    |> validate_required([
      :token_type,
      :order_code
    ])
    # ad token code
    |> add_token_code()
  end

  defp add_token_code(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:token_code, Generator.generate())
  end # end of the add token code function
  defp add_token_code(changeset), do: changeset

end # end of the module definition
