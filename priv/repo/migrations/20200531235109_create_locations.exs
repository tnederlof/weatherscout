defmodule WeatherScout.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS cube", ""
    execute "CREATE EXTENSION IF NOT EXISTS earthdistance", ""

    create table(:locations) do
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :name, :string, null: false
      add :distance, :float, null: false
      add :elevation, :float, null: false
      add :user_save, :boolean, default: false, null: false
      add :user_id, references(:users), null: false
      add :station_id, references(:stations, type: :string), null: false

      timestamps()
    end

    create unique_index(:locations, [:user_id, :name])
  end
end
