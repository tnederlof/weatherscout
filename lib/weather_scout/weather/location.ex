defmodule WeatherScout.Weather.Location do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  @derive {Poison.Encoder, only: [:distance, :elevation, :latitude, :longitude, :name, :user_save, :user, :station]}
  schema "locations" do
    field :distance, :float
    field :elevation, :float
    field :latitude, :float
    field :longitude, :float
    field :name, :string
    field :user_save, :boolean, default: false

    belongs_to :user, WeatherScout.Accounts.User
    belongs_to :station, WeatherScout.Weather.Station, [foreign_key: :station_id, type: :string]


    timestamps()
  end
  @doc false
  def changeset(location, attrs) do
    required_fields = [:latitude, :longitude, :name, :station_id, :distance, :elevation]
    optional_fields = [:user_save]

    location
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:station)
    |> unique_constraint([:user_id, :name], message: "A location with the same name already exists")
  end
end
