defmodule WynixWeb.Servers.Orders do
  @moduledoc """
    Manages orders that are available
  """
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    {:ok, :undefined}
  end # end of the init/1
  
end # end of Orders server
