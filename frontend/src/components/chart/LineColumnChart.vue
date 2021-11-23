<template>
  <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
    <h3 class="text-xl text-gray-600 mb-4">{{ title }}</h3>
    <div>
      <loading v-show="!loaded"/>
      <apexchart v-show="loaded"
      ref="realtimeChart"
      :type="constants.chartTypes.Line"
      :height="300"
      :options="options"
      :series="series" />
    </div>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Loading from '@/components/Loading.vue';
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  name: "LineColumnChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    request: Object
  },
  mounted() {
    // POST request to fetch data for the line-column chart
    fetch(
        constants.server + "/api/data/read", // endpoint
        httpReq.post(this.request) // requestOptions
      )
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok || !data.data) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.updateChart(data.data);
      })
      .catch(error => {
        this.errorMessage = error;
        console.error('LineColumnChart error: ', error);
        this.loaded = true;
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
      loaded: false,
      constants: constants
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
        timeLabels.push(new Date(data[i].timestamp).
          toLocaleDateString("en", constants.timeFormat))
        powerSeries.push((data[i].value).toFixed(2))
        cumulativeEnergy += (data[i].value / 12) // interval 5 min = 1/12 h
        energySeries.push(cumulativeEnergy.toFixed(2))
      }

      const leftAxis = "Average Power (kW)";
      const rightAxis = "Cumulative Energy (kWh)";
      this.options = {
        chart: {
          height: 350,
          type: constants.chartTypes.Line
        },
        stroke: {
          width: [0, 4],
        },
        labels: timeLabels,
        series: [
          {
            name: leftAxis,
            type: constants.chartTypes.Column,
            data: powerSeries
          },
          {
            name: rightAxis,
            type: constants.chartTypes.Line,
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