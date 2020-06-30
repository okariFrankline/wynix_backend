defmodule WynixWeb.Schema.Types.Practise do
  use Absinthe.Schema.Notation

  # practise object
  object :practise do
    field :id, non_null(:id)
    field :bio, :string
    field :cities, non_null(list_of(:string))
    field :countries, non_null(list_of(:string))
    field :practise_name, :string
    field :practise_code, non_null(:string)
    field :practise_type, non_null(:string)
    field :rank, non_null(:string)
    field :rating, :integer
    field :operate_outside_base_location, non_null(:string)
    field :skills, non_null(list_of(:string))
    field :professional_level, :string
  end # end of practise

  # bid object
  object :bid do
    field :id, non_null(:id)
    field :asking_amount, non_null(:decimal)
    field :deposit_amount, :decimal
    field :status, non_null(:string)
    field :order_id, non_null(:id)
  end # end of bid object

  # practise error
  object :practise_error do
    field :key, non_null(:string)
    field :message, non_null(:string)
  end # end of practise error

  # object practise result
  object :practise_result do
    field :practise, non_null(:practise)
    field :errors, list_of(:practise_error)
  end # end of practise result

  # practise input object
  object :practise_input do
    field :practise_name, non_null(:string)
    field :professional_level, non_null(:string)
    field :operate_outside_base_location, non_null(:boolean)
  end # end practise input

  # input for the cities
  object :cities_input do
    field :cities, non_null(list_of(non_null(:string)))
  end # end of cities input

  # input for the countries
  object :countries_input do
    field :countries, non_null(list_of(non_null(:string)))
  end # end of cities input

  # input for the skills
  object :skills_input do
    field :skills, non_null(list_of(non_null(:string)))
  end # end of cities input

  # bio input object
  input_object :bio_input do
    field :bio, non_null(:string)
  end # end of bio input

  # object query
  object :practise_queries do
    @desc "Get practise returns the practise identified by a given id"
    field :get_practise, non_null(:practise_result) do
      arg :practise_id, non_null(:id)

      resolve(&Resolver.get-practise/3)
    end # end of gt practise

    @desc "Get practise bids returns all the bids for a given bid"
    field :get_practise_bids, non_null(list_of(:bid)) do
      arg :practise_id, non_null(:id)

      resolve(&Resolver.get_practise_bids/3)
    end # end of get bids for practise
  end # end of object queries

  # practise mutations
  object :practise_mutations do
    @desc "Update practise updates the details of a given practise identified by a given practise"
    field :update_practise, non_null(:practise_result) do
      arg :practise_id, non_null(:id)
      arg :input, non_null(:practise_input)

      resolve(&Resolver.update_practise/3)
    end # end of update practise

    @desc "Update cities updates the given practise's areas of operation"
    field :update_cities, non_null(:practise_result) do
      arg :practise_id, non_null(:id)
      arg :input, non_null(:citiesinput)

      resolve(&Resolver.add_cities/3)
    end # end of update cities

    @desc "Update countries updates the given practise's of operation"
    field :update_countries, non_null(:practise_result) do
      arg :practise_id, non_null(:id)
      arg :input, non_null(:countries_input)

      resolve(&Resolver.add_countries/3)
    end # end of update countries

    @desc "Update skills updates the skills of a given practise"
    field :update_skills, non_null(:practise_result) do
        arg :practise_id, non_null(:id)
        arg :input, non_null(:skills_input)

        resolve(&Resolver.add_skills/3)
    end # end of update_skills
  end # end of the practise mutations

end # end of the module for practise
