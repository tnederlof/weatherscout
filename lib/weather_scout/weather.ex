defmodule WeatherScout.Weather do
  import Ecto.Query, warn: false
  alias WeatherScout.Repo

  alias WeatherScout.Weather.{Station, Location}
  alias WeatherScout.Accounts.User

  @doc """
  Returns a list of all weather stations
  """
  def list_stations do
    Repo.all(Station)
  end

  def list_stations(criteria) do
    query = from(s in Station)

    Enum.reduce(criteria, query, fn
      {:limit, limit}, query ->
        from s in query, limit: ^limit

      {:order, order}, query ->
        from s in query, order_by: [{^order, :name}]
    end)
    |> Repo.all()
  end

  @doc """
  Returns a list of all locations for a certain user.
  """
  def list_user_locations(%User{} = user) do
    query =
      from l in Location,
        where: l.user_id == ^user.id,
        order_by: [desc: l.inserted_at]

    Repo.all(query) |> Repo.preload([:station])
  end

  @doc """
  Returns a specific weather station with the given `id`.
  """
  def get_station!(id) do
    Repo.get!(Station, id)
  end

  @doc """
  Returns a specific location with the given `id`.
  This preloads the station and observations
  """
  def get_location!(id) do
    Location
    |> Repo.get!(id)
    |> Repo.preload(station: :observations)
  end

  def get_user_location(%User{} = user, id) do
    query =
      from l in Location,
        where: l.user_id == ^user.id and l.id == ^id

    query
    |> Repo.fetch()
  end

  def get_location_by_lat_long(%User{} = user, %{latitude: latitude, longitude: longitude}) do
    query =
      from l in Location,
        where: l.user_id == ^user.id and l.latitude == ^latitude and l.longitude == ^longitude

    query
    |> Repo.fetch()
    |> broadcast_location(:location_updated)
  end

  @doc """
  Change a location
  """
  def change_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
    |> broadcast_location(:location_updated)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.
  ## Examples
      iex> change_location(location)
      %Ecto.Changeset{source: %Location{}}
  """
  def change_location(%Location{} = location) do
    Location.changeset(location, %{})
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Creates a location for the given user.
  """
  def create_location(%User{} = user, attrs) do
    # find the distance to the nearest weather station
    distance_query = """
      SELECT *
      FROM (
        SELECT name, id,
        (point(longitude, latitude)<@>point($2, $1)) as distance
        FROM stations
      ) as a
      ORDER BY distance
    """

    lat = Map.get(attrs, :latitude)
    long = Map.get(attrs, :longitude)

    raw_distance_results =
      Ecto.Adapters.SQL.query!(WeatherScout.Repo, distance_query, [lat, long])

    [head | _tail] = Map.get(raw_distance_results, :rows)

    full_attrs =
      attrs
      |> Map.put(:station_id, Enum.at(head, 1))
      |> Map.put(:distance, Enum.at(head, 2))

    # retrieve the elevation of the location
    # more details about Bing elevation services at
    # https://docs.microsoft.com/en-us/bingmaps/rest-services/elevations/get-elevations
    api_key = Application.fetch_env!(:virtual_earth_elevation, :api_key)

    url =
      "http://dev.virtualearth.net/REST/v1/Elevation/List?points=#{lat},#{long}&key=#{api_key}"

    api_response =
      case HTTPoison.get(url, [], hackney: [:insecure]) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          parse_api_string(body)

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          nil

        {:error, %HTTPoison.Error{reason: _reason}} ->
          nil
      end

    final_attrs =
      full_attrs
      |> Map.put(:elevation, api_response)

    # add in new attributes, set the user and insert the location into the database
    location =
      %Location{}
      |> Location.changeset(final_attrs)
      |> Ecto.Changeset.put_assoc(:user, user)
      |> Repo.insert()
      |> broadcast_location(:location_created)
  end

  defp parse_api_string(api_string) do
    {:ok,
     %{
       "resourceSets" => [
         %{
           "resources" => [
             %{
               "elevations" => [elevation]
             }
           ]
         }
       ]
     }} = Poison.decode(api_string)

    elevation * 3.28084
  end

  def subscribe_to_user_locations(%User{} = user) do
    topic_name = "location_" <> Integer.to_string(user.id)
    Phoenix.PubSub.subscribe(WeatherScout.PubSub, topic_name)
  end

  defp broadcast_location({:error, _reason} = error, _event), do: error

  defp broadcast_location({:ok, location}, event) do
    topic_name = "location_" <> Integer.to_string(location.user_id)
    preloaded_location = Repo.preload(location, station: :observations)
    Phoenix.PubSub.broadcast(WeatherScout.PubSub, topic_name, {event, preloaded_location})
    {:ok, location}
  end
end
