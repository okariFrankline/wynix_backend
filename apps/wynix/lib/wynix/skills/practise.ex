defmodule Wynix.Skills.Practise do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wynix.Utils.Generator

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "practises" do
    field :bio, :string
    field :city, :string, virtual: true
    field :cities, {:array, :string}
    field :country, :string, virtual: true
    field :countries, {:array, :string}
    field :practise_name, :string
    field :practise_code, :string
    field :practise_type, :string
    field :rank, :string
    field :rating, :integer
    field :operate_outside_base_location, :boolean, default: false
    field :skills, {:array, :string}
    field :professional_level, :string

    # relationships
    belongs_to :account, Wynix.Skills.Account

    timestamps()
  end

  @doc false
  def changeset(practise, attrs) do
    practise
    |> cast(attrs, [
      :practise_code,
      :practise_name,
      :rank,
      :practise_type,
      :rating,
      :bio,
      :countries,
      :cities,
      :skills
    ])

  end

  @doc false
  def creation_changeset(practise, attrs) do
    changeset(practise, attrs)
    # ensure the required fields are given
    |> validate_required([
      :account_id,
      :practise_type,
    ])
    # add the practise code
    |> add_practise_code()
  end # end of creation_changeset/2

  @doc false
  def add_cities_changeset(practise, attrs) do
    changeset(practise, attrs)
    |> cast(attrs, [
      :city
    ])
    |> validate_required([
      :city
    ])
    |> validate_city_not_repeated()
    # add city to the list
    |> add_to_cities()
  end # end of the add_city_changeset/2

  @doc false
  def update_bio_changeset(practise, attrs) do
    changeset(practise, attrs)
    |> validate_required([
      :bio
    ])
  end # end of the update_bio_changeset/2

  @doc false
  def add_countries_changeset(practise, attrs) do
    changeset(practise, attrs)
    |> cast(attrs, [
      :country
    ])
    |> validate_required([
      :country
    ])
    |> validate_country_not_repeated()
    # add city to the list
    |> add_to_countries()
  end # end of the add_country_changeset/2

  @doc false
  def add_skills_changeset(practise, attrs) do
    changeset(practise, attrs)
    |> cast(attrs, [
      :skills
    ])
    |> validate_required([
      :skills
    ])
    |> validate_skills_not_repeated()
  end # end of the add_skill_changeset/2

  defp add_practise_code(%Ecto.Changeset{valid?: true} = changeset) do
    changeset
    |> put_change(:practise_code, Generator.generate())
  end
  defp add_practise_code(changeset), do: changeset

  # validate city not repeated ensures that the entered city is not already in the list current cities
  defp validate_city_not_repeated(%Ecto.Changeset{valid?: true, changes: %{city: city}, data: %__MODULE__{cities: cities}} = changeset) do
    if city in cities do
      # add error
      changeset |> add_error(:city, "Failed! The city #{city} is already in your cities of operation list.")
    else
      # return the changeset
      changeset
    end # end of checking if city is in cities
  end # end of validate_city_not_repeated/1
  defp validate_city_not_repeated(changeset), do: changeset

  # add to cities adds the new city to the current list of cities
  defp add_to_cities(%Ecto.Changeset{valid?: true, changes: %{city: city}, data: %__MODULE__{cities: cities}} = changeset) do
    changeset
    |> put_change(:cities, [city | cities])
  end # end of add_to_city/2 when the changeset is valid
  defp add_to_cities(changeset), do: changeset

  # validate country not repeated ensures that the entered city is not already in the list current cities
  defp validate_country_not_repeated(%Ecto.Changeset{valid?: true, changes: %{country: country}, data: %__MODULE__{countries: countries}} = changeset) do
    if country in countries do
      # add error
      changeset |> add_error(:country, "Failed! The country #{country} is already in your countries of operation list.")
    else
      # return the changeset
      changeset
    end # end of checking if country is in cities
  end # end of validate_city_not_repeated/1
  defp validate_country_not_repeated(changeset), do: changeset

  # add to cities adds the new city to the current list of cities
  defp add_to_countries(%Ecto.Changeset{valid?: true, changes: %{country: country}, data: %__MODULE__{countries: countries}} = changeset) do
    changeset
    |> put_change(:countries, [country | countries])
  end # end of add_to_city/2 when the changeset is valid
  defp add_to_countries(changeset), do: changeset

  # validate_skills_not_repeated checks to ensure that the list of new skills is not repeated.
  # by filtering the the list to only include skills not in the current list of skills
  defp validate_skills_not_repeated(%Ecto.Changeset{valid?: true, changes: %{cities: cities}, data: %__MODULE__{cities: current_cities}} = changeset) do
    # check if the current list of cities is empty
    case current_cities do
      # the list is empty
      [] -> changeset
      # current cities is not valid
      _list ->
        cities = Enum.filter(cities, fn city ->
          # return the city that is not in the current cities list
          if Enum.member?(current_cities, city) do
            city
          end # end of if
        end)
        # put the new list of cities to the changeset
        changeset |> put_change(:cities, [cities | current_cities])
    end # end of case for checking if the current cities list is not empty
  end # end of validate_skills_not_repeated/2 when the changeset is valid
  defp validate_skills_not_repeated(changeset), do: changeset

end # end of the practise module
