<template>
  <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
    <h3 class="text-xl text-gray-600 mb-4">{{ title }}</h3>
    <div>
      <loading v-show="!loaded"/>
      <apexchart v-show="loaded"
      ref="realtimeChart"
      type="line"
      :height="300"
      :options="options"
      :series="series" />
    </div>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Loading from '@/components/Loading.vue';

export default {
  name: "LineColumnChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    request: String
  },
  created() {
    // POST request to fetch data for the line-column chart
    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: this.request
    };
    fetch('http://ec2-18-144-174-142.us-west-1.compute.amazonaws.com:5000/api/data/read', requestOptions)
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.updateChart(data.data);
      })
      .catch(error => {
        this.errorMessage = error;
        console.error('There was an error!', error);
      });
  },
  setup() {
    return {
      options: {},
      series:[]
    };
  },
  watch: {
    title: {
      immediate: true,
      handler() {
        document.title = this.title;
      }
    },
    request: {
      immediate: true,
      handler() {
        document.request = this.request;
      }
    }
  },
  data() {
    return {
      loaded: false
    };
  },
  methods: {
    updateChart(data) {
      if (!data) {
        return;
      }
      let timeLabels = [], powerSeries = [], energySeries = []
      let cumulativeEnergy = 0;
      for (let i = 0; i < data.length; i++) {
        timeLabels.push(new Date(data[i].timestamp).toLocaleTimeString("en", {hour: "numeric", minute:"numeric"}))
        powerSeries.push(data[i].value)
        cumulativeEnergy += (data[i].value / 12000) // interval 5 min = 1/12 h, W = 1/1000 kW
        energySeries.push(cumulativeEnergy.toFixed(2))
      }

      const leftAxis = "Average Power (W)";
      const rightAxis = "Average Energy (kWh)";
      this.options = {
        chart: {
          height: 350,
          type: "line",
        },
        stroke: {
          width: [0, 4],
        },
        labels: timeLabels,
        series: [
          {
            name: leftAxis,
            type: "column",
            data: powerSeries
          },
          {
            name: rightAxis,
            type: "line",
            data: energySeries
          },
        ],
        xaxis: {
          type: "time",
        },
        yaxis: [
          {
            title: {
              text: leftAxis,
            }
          },
          {
            opposite: true,
            title: {
              text: rightAxis,
            },
          },
        ],
      };

      this.$refs.realtimeChart.updateOptions(this.options, true);
      this.loaded = true;
    }
  }
};
</script>