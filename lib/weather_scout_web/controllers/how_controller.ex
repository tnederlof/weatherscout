defmodule WeatherScoutWeb.HowController do
  use WeatherScoutWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
