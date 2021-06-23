defmodule WeatherScout.Repo.Migrations.CreateObservationIndex do
  use Ecto.Migration

  def change do
    create index(:observations, [:station_id])
  end
end
