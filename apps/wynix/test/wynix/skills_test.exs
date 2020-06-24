defmodule Wynix.SkillsTest do
  use Wynix.DataCase

  alias Wynix.Skills

  describe "practises" do
    alias Wynix.Skills.Practise

    @valid_attrs %{bio: "some bio", cities: [], countries: [], email: "some email", phone: "some phone", practise_code: "some practise_code", practise_type: "some practise_type", rank: "some rank", rating: 42}
    @update_attrs %{bio: "some updated bio", cities: [], countries: [], email: "some updated email", phone: "some updated phone", practise_code: "some updated practise_code", practise_type: "some updated practise_type", rank: "some updated rank", rating: 43}
    @invalid_attrs %{bio: nil, cities: nil, countries: nil, email: nil, phone: nil, practise_code: nil, practise_type: nil, rank: nil, rating: nil}

    def practise_fixture(attrs \\ %{}) do
      {:ok, practise} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Skills.create_practise()

      practise
    end

    test "list_practises/0 returns all practises" do
      practise = practise_fixture()
      assert Skills.list_practises() == [practise]
    end

    test "get_practise!/1 returns the practise with given id" do
      practise = practise_fixture()
      assert Skills.get_practise!(practise.id) == practise
    end

    test "create_practise/1 with valid data creates a practise" do
      assert {:ok, %Practise{} = practise} = Skills.create_practise(@valid_attrs)
      assert practise.bio == "some bio"
      assert practise.cities == []
      assert practise.countries == []
      assert practise.email == "some email"
      assert practise.phone == "some phone"
      assert practise.practise_code == "some practise_code"
      assert practise.practise_type == "some practise_type"
      assert practise.rank == "some rank"
      assert practise.rating == 42
    end

    test "create_practise/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Skills.create_practise(@invalid_attrs)
    end

    test "update_practise/2 with valid data updates the practise" do
      practise = practise_fixture()
      assert {:ok, %Practise{} = practise} = Skills.update_practise(practise, @update_attrs)
      assert practise.bio == "some updated bio"
      assert practise.cities == []
      assert practise.countries == []
      assert practise.email == "some updated email"
      assert practise.phone == "some updated phone"
      assert practise.practise_code == "some updated practise_code"
      assert practise.practise_type == "some updated practise_type"
      assert practise.rank == "some updated rank"
      assert practise.rating == 43
    end

    test "update_practise/2 with invalid data returns error changeset" do
      practise = practise_fixture()
      assert {:error, %Ecto.Changeset{}} = Skills.update_practise(practise, @invalid_attrs)
      assert practise == Skills.get_practise!(practise.id)
    end

    test "delete_practise/1 deletes the practise" do
      practise = practise_fixture()
      assert {:ok, %Practise{}} = Skills.delete_practise(practise)
      assert_raise Ecto.NoResultsError, fn -> Skills.get_practise!(practise.id) end
    end

    test "change_practise/1 returns a practise changeset" do
      practise = practise_fixture()
      assert %Ecto.Changeset{} = Skills.change_practise(practise)
    end
  end
end
