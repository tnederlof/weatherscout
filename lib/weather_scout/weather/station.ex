defmodule WeatherScout.Weather.Station do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  @derive {Phoenix.Param, key: :id}
  @timestamps_opts [type: :utc_datetime]

  @derive {Poison.Encoder, only: [:elevation, :latitude, :longitude, :name, :post_office, :state, :wmoid, :zipcode, :observations]}
  schema "stations" do
    field :elevation, :float
    field :gsnflag, :boolean, default: false
    field :hcnflag, :boolean, default: false
    field :latitude, :float
    field :longitude, :float
    field :name, :string
    field :post_office, :string
    field :state, :string
    field :wmoid, :float
    field :zipcode, :string

    has_many :observations, WeatherScout.Weather.Observation
    has_many :locations, WeatherScout.Weather.Location

    timestamps()
  end

  @doc false
  def changeset(station, attrs) do
    required_fields = [:latitude, :longitude, :elevation, :state, :name, :post_office]
    optional_fields = [:gsnflag, :hcnflag, :wmoid, :zipcode]

    station
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
  end
end
