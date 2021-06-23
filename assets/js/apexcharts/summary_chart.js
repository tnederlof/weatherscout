import ApexCharts from 'apexcharts'

const SummaryChart = {
  createChart(options) {
    var chart = new ApexCharts(document.querySelector("#SummaryChart"), options);
    chart.render();
  },
  chartOptions(seriesData) {
    var options = {
      chart: {
        id: 'SummaryChart',
        height: '350px',
        type: 'line',
        offsetY: 10,
        toolbar: {
          tools: {
            // eslint-disable-next-line prettier/prettier
            download: '<img src="/images/download_icon.png" width="50" height="50" />',
            selection: false,
            zoom: false,
            zoomin: false,
            zoomout: false,
            pan: false,
            reset: false
          }
        }
      },
      colors: ['#FEB019', '#00E396', '#008FFB', '#b019fe'],
      dataLabels: {
        enabled: false
      },
      title: {
        text: 'Historical Temp & Precip',
        margin: 10,
        offsetY: -5,
        floating: true,
        align: 'center'
      },
      legend: {
        position: 'bottom',
        itemMargin: {
          vertical: 5
        }
      },
      stroke: {
        curve: 'straight',
        width: 3
      },
      xaxis: {
        type: 'datetime',
        labels: {
          format: 'MMM'
        }
      },
      yaxis: [
        {
          seriesName: 'Avg Temp',
          labels: {
            formatter(value) {
              return Math.round(value) + '°F'
            }
          },
          show: false
        },
        {
          seriesName: 'Avg Temp',
          labels: {
            formatter(value) {
              return Math.round(value) + '°F'
            }
          },
          title: {
            text: "Temperature"
          }
        },
        {
          seriesName: 'Avg Temp',
          labels: {
            formatter(value) {
              return Math.round(value) + '°F'
            }
          },
          show: false
        },
        {
          seriesName: '% Precip',
          labels: {
            formatter(value) {
              return value + '%'
            }
          },
          title: {
            text: "Precipitation"
          },
          opposite: true
        }
      ],
      tooltip: {
        x: {
          format: 'MMM d',
          formatter: undefined
        }
      },
      series: seriesData
    }
    return options
  },
  calcChartData(location) {
    const seriesData = [
      { name: 'Max Avg Temp', data: this.getMaxTempData(location) },
      { name: 'Avg Temp', data: this.getAvgTempData(location) },
      { name: 'Min Avg Temp', data: this.getMinTempData(location) },
      { name: '% Precip', data: this.getAvgPrecipData(location) }
    ]
    return seriesData
  },
  mounted() {
    const selectedLocation = JSON.parse(this.el.dataset.selected_location)
    if ((selectedLocation !== undefined) && (!Array.isArray(selectedLocation))) {
      this.createChart(this.chartOptions(this.calcChartData(selectedLocation)))
    }
  },
  updated() {
    const selectedLocation = JSON.parse(this.el.dataset.selected_location)
    if ((selectedLocation !== undefined) && (!Array.isArray(selectedLocation))) {
      const newSeriesData = this.calcChartData(selectedLocation)
      ApexCharts.exec('SummaryChart', 'updateSeries', newSeriesData, true);
    } else {
      ApexCharts.exec('SummaryChart', 'updateSeries', [], true);
    }
  },
  getAvgTempData(location) {
    return this.filterTempData(location, 'Long-term averages of daily average temperature')
  },
  getMaxTempData(location) {
    return this.filterTempData(location, 'Long-term averages of daily maximum temperature')
  },
  getMinTempData(location) {
    return this.filterTempData(location, 'Long-term averages of daily minimum temperature')
  },
  getAvgPrecipData(location) {
    return this.filterPrecipData(location, '50th percentiles of daily nonzero precipitation totals for 29-day windows centered on each day of the year')
  },
  filterTempData(location, metric) {
    const selectedLocations = location
    const tempAdjustment = this.getDegreeAdjustment(selectedLocations)
    return selectedLocations.station.observations
      .filter((obs) => obs.metric === metric)
      .sort((a, b) => a.month - b.month || a.day - b.day)
      .map((obs) => {
        return {
          x:
            String(obs.month).padStart(2, '0') +
            '/' +
            String(obs.day).padStart(2, '0') +
            '/' +
            '2020',
          y: Math.round((obs.value / 10 + tempAdjustment) * 10) / 10
        }
      })
  },
  filterPrecipData(location, metric) {
    const selectedLocations = location
    return selectedLocations.station.observations
      .filter((obs) => obs.metric === metric)
      .sort((a, b) => a.month - b.month || a.day - b.day)
      .map((obs) => {
        return {
          x:
            String(obs.month).padStart(2, '0') +
            '/' +
            String(obs.day).padStart(2, '0') +
            '/' +
            '2020',
          y: obs.value
        }
      })
  },
  getDegreeAdjustment(location) {
    return (
      ((this.getStationElevation(location) - this.getLocationElevation(location)) / 1000) *
      3.57
    )
  },
  getStationElevation(location) {
    // multiply by 3.28084 to go from meters to ft
    return location.station.elevation * 3.28084
  },
  getLocationElevation(location) {
    // do not multiply as this elevation is already in feet
    return location.elevation
  }
}

export default SummaryChart