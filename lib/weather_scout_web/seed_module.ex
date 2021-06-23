
alias WeatherScout.Weather.Station
alias WeatherScout.Weather.Observation

defmodule WeatherScout.Seeds do
  def row_to_station(row, output_type \\ "struct") do

    case output_type do
      "struct" -> %Station{
        id: row["id"],
        latitude: to_float_single(row["latitude"]),
        longitude: to_float_single(row["longitude"]),
        elevation: to_float_single(row["elevation"]),
        state: row["state"],
        name: row["name"],
        gsnflag: to_boolean(row["gsnflag"]),
        hcnflag: to_boolean(row["hcnflag"]),
        wmoid: to_float_single(row["wmoid"]),
        zipcode: zipcode_to_string(row["zipcode"]),
        post_office: row["post_office"]
      }
      _ -> %{
        id: row["id"],
        latitude: to_float_single(row["latitude"]),
        longitude: to_float_single(row["longitude"]),
        elevation: to_float_single(row["elevation"]),
        state: row["state"],
        name: row["name"],
        gsnflag: to_boolean(row["gsnflag"]),
        hcnflag: to_boolean(row["hcnflag"]),
        wmoid: to_float_single(row["wmoid"]),
        zipcode: zipcode_to_string(row["zipcode"]),
        post_office: row["post_office"],
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      }
    end
  end

  @spec row_to_observation(nil | maybe_improper_list | map) ::
          WeatherScout.Weather.Observation.t()
  def row_to_observation(row, output_type \\ "struct") do
    case output_type do
      "struct" -> %Observation{
        station_id: row["id"],
        metric: row["metric"],
        month: to_int_single(row["month"]),
        day: to_int_single(row["day"]),
        value: to_int_single(row["value"]),
        flag: row["flag"]
      }
      _ ->  %{
        station_id: row["id"],
        metric: row["metric"],
        month: to_int_single(row["month"]),
        day: to_int_single(row["day"]),
        value: to_int_single(row["value"]),
        flag: row["flag"],
        inserted_at: DateTime.truncate(DateTime.utc_now(), :second),
        updated_at: DateTime.truncate(DateTime.utc_now(), :second)
      }
    end
  end


  def to_boolean("FALSE"), do: false
  def to_boolean("TRUE"), do: true

  def to_float_single(string_float) do
    {x, _} = case string_float do
      "NA" -> {nil, nil}
      _ -> Float.parse(string_float)
    end
    x
  end

  def to_int_single(string_int) do
    {x, _} = case string_int do
      "NA" -> {nil, nil}
      _ -> Integer.parse(string_int)
    end
    x
  end

  def zipcode_to_string(zipcode) do
    case zipcode do
      "NA" -> nil
      _ -> String.pad_leading(zipcode, 5, "0")
    end
  end

end
