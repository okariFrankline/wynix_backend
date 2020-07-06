defmodule Wynix.Skills.Practise do
  use Ecto.Schema
  import Ecto.Changeset

  alias Wynix.Utils.Generator

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "practises" do
    field :bio, :string
    field :cities, {:array, :string}
    field :countries, {:array, :string}
    field :practise_name, :string
    field :practise_code, :string
    field :practise_type, :string, defaults: "Freelance Practise"
    field :rank, :string
    field :rating, :float
    field :operate_outside_base_location, :boolean, default: false
    field :skills, {:array, :string}
    field :professional_level, :string, default: "Amateur"

    # relationships
    belongs_to :account, Wynix.Skills.Account

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
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

  @spec creation_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def creation_changeset(practise, attrs) do
    changeset(practise, attrs)
    # ensure the required fields are given
    |> validate_required([
      :account_id,
      :practise_type,
      :practise_name
    ])
    # add the practise code
    |> add_practise_code()
  end # end of creation_changeset/2

  @spec add_cities_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def add_cities_changeset(practise, attrs) do
    changeset(practise, attrs)
    |> validate_required([
      :cities
    ])
    |> validate_cities_not_repeated()

  end # end of the add_city_changeset/2

  @spec update_bio_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def update_bio_changeset(practise, attrs) do
    changeset(practise, attrs)
    |> validate_required([
      :bio
    ])
  end # end of the update_bio_changeset/2

  @spec add_countries_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def add_countries_changeset(practise, attrs) do
    changeset(practise, attrs)
    |> validate_required([
      :countries
    ])
    |> validate_countries_not_repeated()
  end # end of the add_country_changeset/2

  @spec add_skills_changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def add_skills_changeset(practise, attrs) do
    changeset(practise, attrs)
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
  defp validate_skills_not_repeated(%Ecto.Changeset{valid?: true, changes: %{skills: skills}, data: %__MODULE__{skills: current_skills}} = changeset) do
    case current_skills do
      # the list of current skills is empty
      [] ->
        # put the new skills into the changeset
        changeset |> put_change(:skills, skills)

      # current list contains a list of skills
      _list ->
        # get the skills not repeated
        skills = Enum.filter(skills, fn skill ->
            if not Enum.member?(current_skills, skill) do
              skill
            end # end of if
        end)
        # add the new skills to the current skills
        changeset |> put_change(:skills, [skills | current_skills])
    end # end of case
  end # end of validate_city_not_repeated/1
  defp validate_skills_not_repeated(changeset), do: changeset

  # validate country not repeated ensures that the entered city is not already in the list current cities
  defp validate_countries_not_repeated(%Ecto.Changeset{valid?: true, changes: %{countries: countries}, data: %__MODULE__{countries: current_countries}} = changeset) do
    case current_countries do
      # no current country in the list
      [] ->
        changeset |> put_change(:countries, countries)
      # the current countries contains a list of countries
      _list ->
        # get list of countries not in the list of current countries
        countries = Enum.filter(countries, fn country ->
          if not Enum.member?(current_countries, country) do
            country
          end # end of if
        end) # end of enum
        # put the new list of countries to the changeset
        changeset |> put_change(:countries, [countries | current_countries])
    end # end of checking the values of the current countries
  end # end of validate_city_not_repeated/1
  defp validate_countries_not_repeated(changeset), do: changeset

  # validate_skills_not_repeated checks to ensure that the list of new skills is not repeated.
  # by filtering the the list to only include skills not in the current list of skills
  defp validate_cities_not_repeated(%Ecto.Changeset{valid?: true, changes: %{cities: cities}, data: %__MODULE__{cities: current_cities}} = changeset) do
    # check if the current list of cities is empty
    case current_cities do
      # the list is empty
      [] -> changeset |> put_change(:cities, cities)
      # current cities is not valid
      _list ->
        cities = Enum.filter(cities, fn city ->
          # return the city that is not in the current cities list
          if not Enum.member?(current_cities, city) do
            city
          end # end of if
        end)
        # put the new list of cities to the changeset
        changeset |> put_change(:cities, [cities | current_cities])
    end # end of case for checking if the current cities list is not empty
  end # end of validate_skills_not_repeated/2 when the changeset is valid
  defp validate_cities_not_repeated(changeset), do: changeset

end # end of the practise module
