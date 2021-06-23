defmodule WeatherScout.Repo.Migrations.CreateStations do
  use Ecto.Migration

  def change do
    create table(:stations, primary_key: false) do
      add :id, :string, primary_key: true
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :elevation, :float, null: false
      add :state, :string, null: false
      add :name, :string, null: false
      add :gsnflag, :boolean
      add :hcnflag, :boolean
      add :wmoid, :float
      add :zipcode, :string
      add :post_office, :string

      timestamps()
    end

    create unique_index(:stations, [:id])
  end
end
