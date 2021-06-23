defmodule WeatherScoutWeb.AboutController do
  use WeatherScoutWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
