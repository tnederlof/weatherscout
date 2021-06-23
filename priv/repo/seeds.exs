# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
alias WeatherScout.Repo
alias WeatherScout.Weather.{Location, Station}
alias WeatherScout.Accounts.User
alias WeatherScout.Accounts


# Load in the observations used by the stations linked to locations
first_obs_data = CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temperature_data_USC00012209.csv")), headers: true)
  |> Enum.map(fn {:ok, row} -> WeatherScout.Seeds.row_to_observation(row) end)
second_obs_data = CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temperature_data_USC00010390.csv")), headers: true)
  |> Enum.map(fn {:ok, row} -> WeatherScout.Seeds.row_to_observation(row) end)
third_obs_data = CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temperature_data_USC00010063.csv")), headers: true)
  |> Enum.map(fn {:ok, row} -> WeatherScout.Seeds.row_to_observation(row) end)
fourth_obs_data = CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temperature_data_USC00012096.csv")), headers: true)
  |> Enum.map(fn {:ok, row} -> WeatherScout.Seeds.row_to_observation(row) end)



tnederlof = %User{} |> User.registration_changeset(%{
      email: "tnederlof@gmail.com",
      password: "TestingTesting!"
    }) |> Repo.insert!
Accounts.confirm_user_manual(tnederlof)

kpotter = %User{} |> User.registration_changeset(%{
  email: "keelapotter@gmail.com",
  password: "TestingTesting!"
    }) |> Repo.insert!
Accounts.confirm_user_manual(kpotter)

    station1 = %Station{
      id: "USC00012209",
      latitude: 34.5569,
      longitude: -86.9503,
      elevation: 178.3,
      state: "AL",
      name: "DECATUR 5SE",
      gsnflag: false,
      hcnflag: false,
      wmoid: nil,
      zipcode: "35601",
      post_office: "Decatur",
      observations: first_obs_data
    } |> Repo.insert!

    station2 = %Station{
    id: "USC00010390",
    latitude: 34.7753,
    longitude: -86.9508,
    elevation: 210.0,
    state: "AL",
    name: "ATHENS",
    gsnflag: false,
    hcnflag: false,
    wmoid: nil,
    zipcode: "35611",
    post_office: "Athens",
    observations: second_obs_data
  } |> Repo.insert!


  station3 = %Station{
    id: "USC00010063",
    latitude: 34.2553,
    longitude: -87.1814,
    elevation: 249.3,
    state: "AL",
    name: "ADDISON",
    gsnflag: false,
    hcnflag: false,
    wmoid: nil,
    zipcode: "35540",
    post_office: "Addison",
    observations: third_obs_data
  } |> Repo.insert!

  station4 = %Station{
    id: "USC00012096",
    latitude: 34.1925,
    longitude: -86.7972,
    elevation: 247.2,
    state: "AL",
    name: "CULLMAN NAHS",
    gsnflag: false,
    hcnflag: false,
    wmoid: nil,
    zipcode: "35055",
    post_office: "Cullman",
    observations: fourth_obs_data
    } |> Repo.insert!


    %Location{
      latitude: 34.7998,
      longitude: -87.6773,
      name: "Florence, AL",
      distance: 870.4,
      elevation: 250.9,
      user_save: true,
      user: tnederlof,
      station: station1
    } |> Repo.insert!


    %Location{
      latitude: 34.1748,
      longitude: -86.8436,
      name: "Cullman, AL",
      distance: 879.4,
      elevation: 120.6,
      user_save: true,
      user: tnederlof,
      station: station2
    } |> Repo.insert!



      %Location{
        latitude: 34.6059,
        longitude: -86.9833,
        name: "Decatur, AL",
        distance: 940.4,
        elevation: 230.2,
        user_save: true,
        user: kpotter,
        station: station3
      } |> Repo.insert!

      %Location{
        latitude: 34.7304,
        longitude: -86.5861,
        name: "Huntsville, AL",
        distance: 940.1,
        elevation: 340.2,
        user_save: true,
        user: kpotter,
        station: station4
      } |> Repo.insert!



# Rest of Stations
CSV.decode(File.stream!(Path.expand("priv/repo/sample_weather_station_data_CAonly.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_station(row)) end)
File.write("stations_complete", "stations_complete")

# Rest of Observations
CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly1.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)
File.write("obs1", "obs1")

CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly2.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)

File.write("obs2", "obs2")
CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly3.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)

File.write("obs3", "obs3")
CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly4.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)

File.write("obs4", "obs4")
CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly5.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)

File.write("obs5", "obs5")
CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly6.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)

File.write("obs6", "obs6")
CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly7.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)

File.write("obs7", "obs7")
CSV.decode(File.stream!(Path.expand("priv/repo/sample_daily_temp_data_CAonly8.csv")), headers: true)
|> Enum.map(fn {:ok, row} -> Repo.insert!(WeatherScout.Seeds.row_to_observation(row)) end)

File.write("obs8", "obs8")
