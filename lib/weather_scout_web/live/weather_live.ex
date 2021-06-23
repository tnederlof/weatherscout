defmodule WeatherScoutWeb.WeatherLive do
  use WeatherScoutWeb, :live_view
  alias WeatherScout.Weather
  alias WeatherScout.Weather.Location
  alias WeatherScout.Repo

  @impl true
  def mount(%{"id" => id}, session, socket) do
    socket = assign_defaults(session, socket)
    if connected?(socket), do: Weather.subscribe_to_user_locations(socket.assigns.current_user)

    locations =
      socket.assigns.current_user
      |> Weather.list_user_locations()

    selected_location =
      cond do
        length(locations) > 0 ->
          case Weather.get_user_location(socket.assigns.current_user, id) do
            {:ok, location} ->
              Repo.preload(location, station: :observations)

            {:error, _changeset} ->
              []
          end

        [] ->
          []
      end

    {:ok,
     assign(socket,
       locations: locations,
       selected_location: selected_location,
       edit_mode: false,
       menu_choice: "summary_historical"
     )}
  end

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(session, socket)
    if connected?(socket), do: Weather.subscribe_to_user_locations(socket.assigns.current_user)

    locations =
      socket.assigns.current_user
      |> Weather.list_user_locations()

    selected_location =
      cond do
        length(locations) > 0 ->
          selected_location_id = List.first(locations).id
          send(self(), {:push_id, selected_location_id})

          case Weather.get_user_location(socket.assigns.current_user, selected_location_id) do
            {:ok, location} ->
              Repo.preload(location, station: :observations)

            {:error, _changeset} ->
              []
          end

        [] ->
          []
      end

    {:ok,
     assign(socket,
       locations: locations,
       selected_location: selected_location,
       edit_mode: false,
       menu_choice: "summary_historical"
     )}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, socket) do
    selected_location =
      case Weather.get_user_location(socket.assigns.current_user, id) do
        {:ok, location} ->
          Repo.preload(location, station: :observations)

        {:error, _changeset} ->
          []
      end

    {:noreply,
     assign(socket,
       selected_location: selected_location
     )}
  end

  def handle_params(_, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({:push_id, id}, socket) do
    {:noreply, push_patch(socket, to: Routes.weather_path(socket, :index, id: id))}
  end

  @impl true
  def handle_event("clear_location", _params, socket) do
    {:noreply, assign(socket, selected_location: [])}
  end

  @impl true
  def handle_event(
        "selected_location",
        %{"location" => %{"lat" => latitude, "lng" => longitude}},
        socket
      ) do
    location_name = "#{Float.round(latitude, 4)}, #{Float.round(longitude, 4)}"
    location_attrs = %{latitude: latitude, longitude: longitude, name: location_name}

    # check to see if the latitude and longitude already exist for a user, if so then just broadcast that
    case Weather.get_location_by_lat_long(socket.assigns.current_user, location_attrs) do
      {:ok, location} ->
        send(self(), {:push_id, location.id})
        {:noreply, socket}

      {:error, _changeset} ->
        case Weather.create_location(socket.assigns.current_user, location_attrs) do
          {:ok, location} ->
            send(self(), {:push_id, location.id})
            {:noreply, socket}

          {:error, changeset} ->
            send(self(), {:rollback, location_attrs})
            {:noreply, socket}
        end
    end
  end

  @impl true
  def handle_event("menu_change", %{"menu_choice" => menu_choice}, socket) do
    {:noreply, assign(socket, menu_choice: menu_choice)}
  end

  @impl true
  def handle_event("edit_location_name", _, socket) do
    changeset =
      Weather.change_location(socket.assigns.selected_location)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, edit_mode: true, changeset: changeset)}
  end

  @impl true
  def handle_event("exit_edit_mode", _, socket) do
    {:noreply, assign(socket, edit_mode: false)}
  end

  @impl true
  def handle_event("save_name", %{"location" => location_params}, socket) do
    case Weather.change_location(socket.assigns.selected_location, location_params) do
      {:ok, _location} ->
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event("save_location", _params, socket) do
    case Weather.change_location(socket.assigns.selected_location, %{"user_save" => true}) do
      {:ok, _location} ->
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_event("unsave_location", _params, socket) do
    selected_location = socket.assigns.selected_location
    new_name = "#{Float.round(selected_location.latitude, 4)}, #{Float.round(selected_location.longitude, 4)}"
    case Weather.change_location(selected_location,
                                %{"user_save" => false, "name" => new_name}) do
      {:ok, _location} ->
        {:noreply, socket}

      {:error, changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_info({:location_created, location}, socket) do
    socket =
      socket
      |> update(:locations, fn locations -> [location | locations] end)
      |> update(:selected_location, fn _selected_location -> location end)
      |> assign(edit_mode: false)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:location_updated, location}, socket) do
    socket =
      socket
      |> update(:locations, fn locations ->
        [location | filter_out_location(locations, location.id)]
      end)
      |> update(:selected_location, fn _selected_location -> location end)
      |> assign(edit_mode: false)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:rollback, _location_params}, socket) do
    socket =
      socket
      |> assign(selected_location: [])
      |> assign(edit_mode: false)
      |> put_flash(:error, "An error has occured. Please try again and contact the site admin.")

    {:noreply, socket}
  end

  defp filter_out_location(locations, id) do
    Enum.filter(locations, &(&1.id != id))
  end

  def location_name_readable(%Location{name: name}), do: name

  def location_name_readable([]), do: "Nothing Selected"

  def number_to_delimited(number, decimals \\ 0) do
    Number.Delimit.number_to_delimited(number, precision: decimals)
  end

  def calc_elevation_diff(location) do
    location.elevation - location.station.elevation * 3.28084
  end

  def calc_temperature_diff(location) do
    calc_elevation_diff(location) / 1000 * 3.57
  end
end
