defmodule WynixWeb.Schema.Middlewares.ChangesetError do
    @moduledoc """
        Creates middleware that will be used to handle Ecto.Chnageset errors
    """
    @behaviour Absinthe.Middleware
    #import Ecto.Changeset

    def call(resolution, _opts) do
        # check if the errors field contains a changeset
        with %{errors: [%Ecto.Changeset{} = changeset]} <- resolution do
            # update the resolution
            %{
                resolution |
                value: %{errors: transform_errors(changeset)},
                errors: []
            }
        end # end of with
    end # end of the call function

    # transfor erros function
    defp transform_errors(changeset) do
        changeset
        |> Ecto.Changeset.traverse_errors(&format_errors/1)
        |> Enum.map(fn {key, value} ->
            %{key: key, message: value}
        end)
    end # end of transform-errors

    defp format_errors({msg, opts}) do
        Enum.reduce(opts, msg, fn({key, value}, acc) ->
            String.replace(acc, "#{key}", to_string(value))
        end)
    end # end of format-erros
end # end of module EjobWeb.Schema.Middlewares.ChangesetError
