defmodule Wynix.Skills do
  @moduledoc """
  The Skills context.
  """

  import Ecto.Query, warn: false
  alias Wynix.Repo

  alias Wynix.Skills.Practise

  @doc """
  Returns the list of practises.

  ## Examples

      iex> list_practises()
      [%Practise{}, ...]

  """
  def list_practises do
    Repo.all(Practise)
  end

  @doc """
  Gets a single practise.

  Raises `Ecto.NoResultsError` if the Practise does not exist.

  ## Examples

      iex> get_practise!(123)
      %Practise{}

      iex> get_practise!(456)
      ** (Ecto.NoResultsError)

  """
  def get_practise!(id), do: Repo.get!(Practise, id)

  @doc """
  Creates a practise.

  ## Examples

      iex> create_practise(%{field: value})
      {:ok, %Practise{}}

      iex> create_practise(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_practise(attrs \\ %{}) do
    %Practise{}
    |> Practise.creation_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a practise.

  ## Examples

      iex> update_practise(practise, %{field: new_value})
      {:ok, %Practise{}}

      iex> update_practise(practise, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practise(%Practise{} = practise, attrs) do
    practise
    |> Practise.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a practise's skills.

  ## Examples

      iex> update_practise_skills(practise, %{field: new_value})
      {:ok, %Practise{}}

      iex> update_practise_skills(practise, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practise_skills(%Practise{} = practise, attrs) do
    practise
    |> Practise.add_skills_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a practise's countries of operation.

  ## Examples

      iex> update_practise_countriess(practise, %{field: new_value})
      {:ok, %Practise{}}

      iex> update_practise_countries(practise, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practise_countries(%Practise{} = practise, attrs) do
    practise
    |> Practise.add_countries_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a practise's cities of operation.

  ## Examples

      iex> update_practise_citiess(practise, %{field: new_value})
      {:ok, %Practise{}}

      iex> update_practise_cities(practise, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practise_cities(%Practise{} = practise, attrs) do
    practise
    |> Practise.add_cities_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a practise's bio.

  ## Examples

      iex> update_practise_bio(practise, %{field: new_value})
      {:ok, %Practise{}}

      iex> update_practise_bio(practise, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_practise_bio(%Practise{} = practise, attrs) do
    practise
    |> Practise.update_bio_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a practise.

  ## Examples

      iex> delete_practise(practise)
      {:ok, %Practise{}}

      iex> delete_practise(practise)
      {:error, %Ecto.Changeset{}}

  """
  def delete_practise(%Practise{} = practise) do
    Repo.delete(practise)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking practise changes.

  ## Examples

      iex> change_practise(practise)
      %Ecto.Changeset{data: %Practise{}}

  """
  def change_practise(%Practise{} = practise, attrs \\ %{}) do
    Practise.changeset(practise, attrs)
  end
end
