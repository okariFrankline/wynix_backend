defmodule WynixWeb.Schema.Practise.Resolver do
  @moduledoc """
    Defines resolver functions for the practise schema type
  """
  #alias Wynix.Skills.{Practise}
  alias Wynix.{Skills, Repo, Contracts}
  import Ecto.Query

  @errors [%{
    key: "Not Found",
    message: "Practise Account Not Found."
  }]

  @doc false
  def get_practise(_parent, args, _resolution) do
    # get the practise with the given id
    practise = Skills.get_practise!(args.practise_id)
    {:ok, %{practise: practise}}
  rescue
    Ecto.NoResultsError ->
      {:ok, %{errors: @errors}}
  end # end of get_practise

  @doc false
  def get_practise_bids(_parent, args, _resolution) do
    # get the practise
    practise = %Contracts.Practise{id: args.practise_id} |> Repo.preload([:bids])
    # return the bids
    {:ok, %{practise: practise}}
  end # end of get_practise_bids/3

  @doc false
  def update_practise(_parent, args, _resolution) do
    with {:ok, practise} <- Skills.get_practise!(args.practise_id) |> Skills.update_practise(args.input), do: {:ok, %{practise: practise}}
  end # end of update_practise.3

  @doc false
  def add_cities(_parent, args, _resolution) do
    with {:ok, practise} <- Skills.get_practise!(args.practise_id) |> Skills.update_practise_cities(args.input), do: {:ok, %{practise: practise}}
  end # end of add_cities/3

  @doc false
  def add_countries(_parent, args, _resolution) do
    with {:ok, practise} <- Skills.get_practise!(args.practise_id) |> Skills.update_practise_countries(args.input), do: {:ok, %{practise: practise}}
  end # end of add_countries/3

  @doc false
  def add_skills(_parent, args, _resolution) do
    with {:ok, practise} <- Skills.get_practise!(args.practise_id) |> Skills.update_practise_skills(args.input), do: {:ok, %{practise: practise}}
  end # end of add_skills/3

end # end of the practise resolver
