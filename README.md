# The Weather Scout

## Overview

Imagine you have a trip coming up. What gear should you prepare? How should you plan your itinerary? Trip planning largely depends on what the weather could bring. The Weather Scout allows for easy exploration of US historical weather data. Have fun exploring! 

This repo contains the following components:
* Frontend code - Phoenix html.eex files, tailwindcss styling, javascript based chart components and mapbox gl based map component.
* Backend code - Elixir code using the Phoenix web framework
* Database seeds - Example data seed files for development

See can see the code in action at: https://www.theweatherscout.com. To deploy this code some API Keys are required and a PostgreSQL databased must be configured and loaded with NOAA normals weather data.

Note: The data used in this site is based on historical weather data and is NOT a prediction of future weather patterns, please check a short-term forcast at weather.gov before heading out on a trip.   

## Background

Every ten years NOAA creates a [climate dataset](https://www.ncdc.noaa.gov/data-access/land-based-station-data/land-based-datasets/climate-normals/1981-2010-normals-data) based on the past 30 years of historical data. Despite containing valuable information, the current access tools are challenging to use, which prevents easy exploration. This Elixir powered Phoenix based web application combines an interactive map with a powerful location search tool, the NOAA Climate Normals dataset and some prediction techniques to create a rich exploration of what temperatures might be at any location in the United States at different points throughout the year.

## Configuration

Three API keys will need to be registered as described below:
* [Mapbox API](https://docs.mapbox.com/help/getting-started/access-tokens/) for location searches and map rendering
* [SendGrid API](https://sendgrid.com/solutions/email-api/) for user signup and password reset email sending
* [Bing Maps API](https://www.microsoft.com/en-us/maps/create-a-bing-maps-key) for elevation data

You will need to create a `releases.exs` file with the following contents.

```elixir
import Config

config :weather_scout,
  mapbox_api_key: "MAPBOXAPIKEYGOESHERE"

config :weather_scout, WeatherScout.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: "SENDGRIDAPIKEYGOESHERE"

config :virtual_earth_elevation,
  api_key: "BINGMAPSAPIKEYGOESHERE"
```

You will need to set the Mapbox API Token in the [frontend code here](https://github.com/tnederlof/weatherscout/blob/main/assets/js/mapbox/mapboxgl.js#L9).

You will need to set your secret key base in the `config.exs` file.

You will need to set the following environment variables in the production environment.
* DATABASE_URL
* SECRET_KEY_BASE

There are many different ways to host a Phoenix application but my recommendation is to use [Render.com](https://render.com/docs/deploy-phoenix).

There are seed data files to create a sample database included in this repo. The full NOAA climate normals dataset is quite large. You can access the data via their [ftp site here](ftp://ftp.ncdc.noaa.gov/pub/data/normals/1981-2010/).


