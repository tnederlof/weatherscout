defmodule WeatherScout.Repo.Migrations.CreateObservations do
  use Ecto.Migration

  def change do
    create table(:observations) do
      add :metric, :string, null: false
      add :month, :integer, null: false
      add :day, :integer, null: false
      add :value, :integer, null: false
      add :flag, :string, null: false
      add :station_id, references(:stations, column: :id, type: :string), null: false

      timestamps()
    end

  end
end
