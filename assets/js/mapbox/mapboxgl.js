import mapboxgl from 'mapbox-gl';
import MapboxGeocoder from '@mapbox/mapbox-gl-geocoder';
import '@mapbox/mapbox-gl-geocoder/dist/mapbox-gl-geocoder.css';
import config from "./config"

const WeatherMap = {
  createMap() {
    // add your own mapbox api token below
    mapboxgl.accessToken = 'MAPBOXAPITOKENGOESHERE';

    var map = new mapboxgl.Map({
      container: 'WeatherMap',
      style: 'mapbox://styles/mapbox/outdoors-v11', // stylesheet location
      center: [-122.4376, 37.7577],
      zoom: 8
    });
    var geocoder = new MapboxGeocoder({
      accessToken: mapboxgl.accessToken,
      mapboxgl: mapboxgl,
      marker: false,
      flyTo: false,
      countries: "US"
    });
    map.addControl(
      geocoder, "top-left"
    );
    map.addControl(
      new mapboxgl.NavigationControl(), "bottom-right"
    );
    const view = this;
    geocoder.on('result', function (result) {
      const longitude = result.result.center[0]
      const latitude = result.result.center[1]

      const mapLayer = map.getLayer('placeHolderPoint')

      if (typeof mapLayer !== 'undefined') {
        // Remove map layer & source.
        map
          .removeLayer('placeHolderPoint')
          .removeSource('placeHolderPoint')
      }

      map.addLayer({
        id: 'placeHolderPoint',
        type: 'symbol',
        source: {
          type: 'geojson',
          data: {
            type: 'FeatureCollection',
            features: [
              {
                type: 'Feature',
                geometry: {
                  type: 'Point',
                  coordinates: [longitude, latitude]
                },
                properties: {
                  icon: 'marker',
                  title: (Math.round(latitude * 10000) / 10000).toString() + ', ' + (Math.round(longitude * 10000) / 10000).toString()
                }
              }
            ]
          },
          tolerance: 0.00001
        },
        layout: {
          'icon-image': '{icon}-15',
          'icon-size': 1.25,
          'text-field': '{title}',
          'text-font': ['Open Sans Semibold', 'Arial Unicode MS Bold'],
          'text-offset': [0, 0.6],
          'text-anchor': 'top',
          'icon-allow-overlap': true,
          'text-allow-overlap': true
        }
      });

      map.flyTo({
        center: [longitude, latitude],
        zoom: 8
      })

      const lngLat = { "lng": longitude, "lat": latitude }
      view.pushEvent("selected_location", { location: lngLat })
    })

    return map
  },
  mounted() {

    this.map = this.createMap()
    const selectedLocation = JSON.parse(this.el.dataset.selected_location)
    const map = this.map

    if ((selectedLocation !== undefined) && (!Array.isArray(selectedLocation))) {
      this.map.on('load', function () {
        map.addLayer({
          id: 'currentLocationPoint',
          type: 'symbol',
          source: {
            type: 'geojson',
            data: {
              type: 'FeatureCollection',
              features: [
                {
                  type: 'Feature',
                  geometry: {
                    type: 'Point',
                    coordinates: [selectedLocation.longitude, selectedLocation.latitude]
                  },
                  properties: {
                    icon: 'campsite',
                    title: selectedLocation.name
                  }
                }
              ]
            },
            tolerance: 0.00001
          },
          layout: {
            'icon-image': '{icon}-15',
            'icon-size': 1.25,
            'text-field': '{title}',
            'text-font': ['Open Sans Semibold', 'Arial Unicode MS Bold'],
            'text-offset': [0, 0.6],
            'text-anchor': 'top',
            'icon-allow-overlap': true,
            'text-allow-overlap': true
          }
        });

        map.flyTo({
          center: [selectedLocation.longitude, selectedLocation.latitude],
          zoom: 8
        })

        // Add weather station point
        map.addLayer({
          id: 'currentStationPoint',
          type: 'symbol',
          source: {
            type: 'geojson',
            data: {
              type: 'FeatureCollection',
              features: [
                {
                  type: 'Feature',
                  geometry: {
                    type: 'Point',
                    coordinates: [selectedLocation.station.longitude, selectedLocation.station.latitude]
                  },
                  properties: {
                    icon: 'communications-tower'
                  }
                }
              ]
            },
            tolerance: 0.00001
          },
          layout: {
            'icon-image': '{icon}-15',
            'icon-size': 1.25,
            'text-field': '{title}',
            'text-font': ['Open Sans Semibold', 'Arial Unicode MS Bold'],
            'text-offset': [0, 0.6],
            'text-anchor': 'top',
            'icon-allow-overlap': true,
            'text-allow-overlap': true
          }
        })
      })
    }


    const view = this;
    // When a click event occurs on a feature in the places layer, open a popup at the
    // location of the feature, with description HTML from its properties.
    this.map.on('click', function (e) {
      const mapLayer = map.getLayer('placeHolderPoint')

      if (typeof mapLayer !== 'undefined') {
        // Remove map layer & source.
        map
          .removeLayer('placeHolderPoint')
          .removeSource('placeHolderPoint')
      }

      map.addLayer({
        id: 'placeHolderPoint',
        type: 'symbol',
        source: {
          type: 'geojson',
          data: {
            type: 'FeatureCollection',
            features: [
              {
                type: 'Feature',
                geometry: {
                  type: 'Point',
                  coordinates: [e.lngLat.lng, e.lngLat.lat]
                },
                properties: {
                  icon: 'marker',
                  title: (Math.round(e.lngLat.lat * 10000) / 10000).toString() + ', ' + (Math.round(e.lngLat.lng * 10000) / 10000).toString()
                }
              }
            ]
          },
          tolerance: 0.00001
        },
        layout: {
          'icon-image': '{icon}-15',
          'icon-size': 1.25,
          'text-field': '{title}',
          'text-font': ['Open Sans Semibold', 'Arial Unicode MS Bold'],
          'text-offset': [0, 0.6],
          'text-anchor': 'top',
          'icon-allow-overlap': true,
          'text-allow-overlap': true
        }
      });
      view.pushEvent("clear_location", { location: e.lngLat })
      view.pushEvent("selected_location", { location: e.lngLat })

    });
  },
  updated() {
    const selectedLocation = JSON.parse(this.el.dataset.selected_location)
    if ((selectedLocation !== undefined) && (!Array.isArray(selectedLocation))) {

      // change the location
      const locationMapLayer = this.map.getLayer('currentLocationPoint')

      if (typeof locationMapLayer !== 'undefined') {
        // Remove map layer & source.
        this.map
          .removeLayer('currentLocationPoint')
          .removeSource('currentLocationPoint')
      }

      this.map.addLayer({
        id: 'currentLocationPoint',
        type: 'symbol',
        source: {
          type: 'geojson',
          data: {
            type: 'FeatureCollection',
            features: [
              {
                type: 'Feature',
                geometry: {
                  type: 'Point',
                  coordinates: [selectedLocation.longitude, selectedLocation.latitude]
                },
                properties: {
                  icon: 'campsite',
                  title: selectedLocation.name
                }
              }
            ]
          },
          tolerance: 0.00001
        },
        layout: {
          'icon-image': '{icon}-15',
          'icon-size': 1.25,
          'text-field': '{title}',
          'text-font': ['Open Sans Semibold', 'Arial Unicode MS Bold'],
          'text-offset': [0, 0.6],
          'text-anchor': 'top',
          'icon-allow-overlap': true,
          'text-allow-overlap': true
        }
      });

      // Remove the placeholder
      const holderMapLayer = this.map.getLayer('placeHolderPoint')

      if (typeof holderMapLayer !== 'undefined') {
        // Remove map layer & source.
        this.map
          .removeLayer('placeHolderPoint')
          .removeSource('placeHolderPoint')
      }

      // change the station
      const mapLayer = this.map.getLayer('currentStationPoint')
      if (typeof mapLayer !== 'undefined') {
        // Remove map layer & source.
        this.map
          .removeLayer('currentStationPoint')
          .removeSource('currentStationPoint')
      }

      // Add weather station point
      this.map.addLayer({
        id: 'currentStationPoint',
        type: 'symbol',
        source: {
          type: 'geojson',
          data: {
            type: 'FeatureCollection',
            features: [
              {
                type: 'Feature',
                geometry: {
                  type: 'Point',
                  coordinates: [selectedLocation.station.longitude, selectedLocation.station.latitude]
                },
                properties: {
                  icon: 'communications-tower'
                }
              }
            ]
          },
          tolerance: 0.00001
        },
        layout: {
          'icon-image': '{icon}-15',
          'icon-size': 1.25,
          'text-field': '{title}',
          'text-font': ['Open Sans Semibold', 'Arial Unicode MS Bold'],
          'text-offset': [0, 0.6],
          'text-anchor': 'top',
          'icon-allow-overlap': true,
          'text-allow-overlap': true
        }
      })
    } else {
      // if the array empty then just remove everything from the map
      const locationMapLayer = this.map.getLayer('currentLocationPoint')
      if (typeof locationMapLayer !== 'undefined') {
        // Remove map layer & source.
        this.map
          .removeLayer('currentLocationPoint')
          .removeSource('currentLocationPoint')
      }
      const mapLayer = this.map.getLayer('currentStationPoint')
      if (typeof mapLayer !== 'undefined') {
        // Remove map layer & source.
        this.map
          .removeLayer('currentStationPoint')
          .removeSource('currentStationPoint')
      }
    }

  }
}

export default WeatherMap
