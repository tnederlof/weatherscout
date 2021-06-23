defmodule WeatherScout.Weather.Observation do
  use Ecto.Schema
  import Ecto.Changeset
  @timestamps_opts [type: :utc_datetime]

  @derive {Poison.Encoder, only: [:day, :flag, :metric, :month, :value]}
  schema "observations" do
    field :day, :integer
    field :flag, :string
    field :metric, :string
    field :month, :integer
    field :value, :integer

    belongs_to :station, WeatherScout.Weather.Station, [type: :string]

    timestamps()
  end

  @doc false
  def changeset(observation, attrs) do
    required_fields = [:metric, :month, :day, :value]
    optional_fields = [:flag]

    observation
    |> cast(attrs, required_fields ++ optional_fields)
    |> validate_required(required_fields)
    |> assoc_constraint(:station)
  end
end
