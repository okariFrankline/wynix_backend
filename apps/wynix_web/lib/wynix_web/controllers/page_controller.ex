defmodule WynixWeb.PageController do
  use WynixWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
