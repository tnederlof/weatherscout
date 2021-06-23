import ApexCharts from 'apexcharts'

const DetailedChart = {
  createChart(options) {
    var chart = new ApexCharts(document.querySelector("#DetailedChart"), options);
    chart.render();
  },
  chartOptions(seriesData) {
    var options = {
      chart: {
        id: 'DetailedChart',
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
      dataLabels: {
        enabled: false
      },
      title: {
        text: 'Historical Temperatures',
        margin: 10,
        offsetY: -5,
        floating: true,
        align: 'center'
      },
      legend: {
        position: 'bottom',
        itemMargin: {
          horizontal: 10,
          vertical: 15
        },
        show: false
      },
      stroke: {
        curve: 'straight',
        width: [2, 3, 2, 2, 3, 2],
        dashArray: [5, 0, 5, 5, 0, 5]
      },
      colors: ['#fec14c', '#FEB019', '#fec14c', '#2fa6ff', '#008FFB', '#2fa6ff'],
      xaxis: {
        type: 'datetime',
        labels: {
          format: 'MMM'
        }
      },
      yaxis: {
        labels: {
          formatter(value) {
            return Math.round(value) + '°F'
          }
        }
      },
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
      { name: 'High Max', data: this.getBandData(location, "max", "add") },
      { name: 'High Avg', data: this.getMaxData(location) },
      { name: 'High Min', data: this.getBandData(location, "max", "subtract") },
      { name: 'Low Max', data: this.getBandData(location, "min", "add") },
      { name: 'Low Avg', data: this.getMinData(location) },
      { name: 'Low Min', data: this.getBandData(location, "min", "subtract") }
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
      ApexCharts.exec('DetailedChart', 'updateSeries', newSeriesData, true);
    } else {
      ApexCharts.exec('DetailedChart', 'updateSeries', [], true);
    }
  },
  getBandData(location, type, operation) {
    if (type == "max") {
      var avgData = this.getMaxData(location)
      var avgSDData = this.getMaxSDData(location)
    } else if (type == "avg") {
      var avgData = this.getAvgData(location)
      var avgSDData = this.getAvgSDData(location)
    } else {
      var avgData = this.getMinData(location)
      var avgSDData = this.getMinSDData(location)
    }
    // if for some reason the std dev doesn't exist just return an empty array
    if (avgSDData.length > 0) {
      let newTemp = avgData.map(observation => {
        const sdData = avgSDData.find(data => data.x === observation.x)
        if (operation == "add") {
          return (observation.x = sdData.x) ? { x: observation.x, y: (Math.round((observation.y + (sdData.y * 2)) * 10) / 10) } : null
        } else {
          return (observation.x = sdData.x) ? { x: observation.x, y: (Math.round((observation.y - (sdData.y * 2)) * 10) / 10) } : null
        }
      })
      return newTemp
    } else {
      return []
    }
  },
  getAvgData(location) {
    const result = this.filterData(location, 'Long-term averages of daily average temperature')
    return result
  },
  getAvgSDData(location) {
    return this.queryData(location, 'Long-term standard deviations of daily average temperature')
  },
  getMaxData(location) {
    return this.filterData(location, 'Long-term averages of daily maximum temperature')
  },
  getMaxSDData(location) {
    return this.queryData(location, 'Long-term standard deviations of daily maximum temperature')
  },
  getMinData(location) {
    return this.filterData(location, 'Long-term averages of daily minimum temperature')
  },
  getMinSDData(location) {
    return this.queryData(location, 'Long-term standard deviations of daily minimum temperature')
  },
  queryData(location, metric) {
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
          y: obs.value / 10
        }
      })
  },
  filterData(location, metric) {
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

export default DetailedChart