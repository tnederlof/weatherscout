defmodule WeatherScoutWeb.LocationsLive do
  use WeatherScoutWeb, :live_view
  alias WeatherScout.Weather
  alias WeatherScout.Weather.Location

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    if connected?(socket), do: Weather.subscribe_to_user_locations(socket.assigns.current_user)

    locations = fetch_user_saved_locations(socket.assigns.current_user)

    {:ok,
     assign(socket,
       locations: locations
     )}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    location = Weather.get_location!(id)
    {:ok, _location} = Weather.delete_location(location)

    {:noreply,
     assign(socket, :locations, fetch_user_saved_locations(socket.assigns.current_user))}
  end

  @impl true
  def handle_info({:location_created, location}, socket) do
    socket =
      socket
      |> update(:locations, fn locations -> [location | locations] end)
      |> assign(edit_mode: false)

    {:noreply, socket}
  end

  defp filter_out_location(locations, id) do
    Enum.filter(locations, &(&1.id != id))
  end

  @impl true
  def handle_info({:location_updated, location}, socket) do
    socket =
      socket
      |> update(:locations, fn locations ->
        [location | filter_out_location(locations, location.id)]
      end)
      |> assign(edit_mode: false)

    {:noreply, socket}
  end

  defp fetch_user_saved_locations(user) do
    user
    |> Weather.list_user_locations()
    |> Enum.filter(&(&1.user_save == true))
  end

  def number_to_delimited(number, decimals \\ 0) do
    Number.Delimit.number_to_delimited(number, precision: decimals)
  end
end
