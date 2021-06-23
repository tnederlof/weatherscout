import ApexCharts from 'apexcharts'

const DetailedPrecipChart = {
  createChart(options) {
    var chart = new ApexCharts(document.querySelector("#DetailedPrecipChart"), options);
    chart.render();
  },
  chartOptions(seriesData) {
    var options = {
      chart: {
        id: 'DetailedPrecipChart',
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
        text: 'Historical Precipitation',
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
        width: 3
      },
      colors: ['#FEB019', '#00E396', '#008FFB'],
      xaxis: {
        type: 'datetime',
        labels: {
          format: 'MMM'
        }
      },
      yaxis: {
        labels: {
          formatter(value) {
            return value + '%'
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
      { name: 'High % Precip', data: this.getHighPrecipData(location) },
      { name: 'Avg % Precip', data: this.getAvgPrecipData(location) },
      { name: 'Low % Precip', data: this.getLowPrecipData(location) }
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
      ApexCharts.exec('DetailedPrecipChart', 'updateSeries', newSeriesData, true);
    } else {
      ApexCharts.exec('DetailedPrecipChart', 'updateSeries', [], true);
    }
  },
  getHighPrecipData(location) {
    return this.filterPrecipData(location, '75th percentiles of daily nonzero precipitation totals for 29-day windows centered on each day of the year')
  },
  getAvgPrecipData(location) {
    return this.filterPrecipData(location, '50th percentiles of daily nonzero precipitation totals for 29-day windows centered on each day of the year')
  },
  getLowPrecipData(location) {
    return this.filterPrecipData(location, '25th percentiles of daily nonzero precipitation totals for 29-day windows centered on each day of the year')
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
  }
}

export default DetailedPrecipChart