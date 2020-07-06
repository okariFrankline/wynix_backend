defmodule Wynix.Utils.Generator do
  @moduledoc """
    Generates random unique codes for the application
  """
  use Puid, total: 20.0e6, risk: 2.0e12, bits: 64
end # end of the puid
