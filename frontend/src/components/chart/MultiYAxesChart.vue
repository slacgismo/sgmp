<template>
  <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
    <h3 class="text-xl text-gray-600 mb-4">{{ title }}</h3>
    <div>
      <loading v-show="!loaded" />
      <apexchart
        v-show="loaded"
        ref="multiAxesChart"
        :type="constants.chartTypes.Line"
        :height="300"
        :options="options"
        :series="series"
      ></apexchart>
    </div>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Loading from "@/components/Loading.vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  name: "MultiYAxesChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    axes: Object,
    request: Object
  },
  mounted() {
    // POST request to fetch data for the 3 y-axis chart
    fetch(
      constants.server + "/api/data/read", // endpoint
      httpReq.post(this.request) // requestOptions
    )
    .then(async response => {
      const data = await response.json();
      // check for error response
      if (!response.ok || !data.results) {
        // get error message from body or default to response status
        const error = (data && data.message) || response.status;
        return Promise.reject(error);
      }

      this.updateChart(data.results);
    })
    .catch(error => {
      this.errorMessage = error;
      console.error(error);
      this.loaded = true;
    });
  },
  setup() {
    return {
      options: {},
      series: [],
    };
  },
  watch: {
    title: {
      immediate: true,
      handler() {
        document.title = this.title;
      },
    },
    axes: {
      immediate: true,
      handler() {
        document.axes = this.axes;
      }
    },
    request: {
      immediate: true,
      handler() {
        document.request = this.request;
      },
    },
  },
  data() {
    return {
      loaded: false,
      constants: constants,
    };
  },
  methods: {
    updateChart(results) {
      if (!results || results.length < 1) {
        this.loaded = true;
        return;
      }

      // unified lengths of all 
      var dataLen = results[0].data.length;
      for (let i = 0; i < results.length; i++) {
        dataLen = Math.min(dataLen, results[i].data.length);
      }

      let timeLabels = [], series = [], strokes = { width: []};
      for (let i = 0; i < this.axes.length; i++) {
        series[i] = {
          name: this.axes[i].title,
          type: this.axes[i].type,
          data: []
        };

        if (this.axes[i].type == constants.chartTypes.Line) {
          strokes.width[i] = 4; // line is not visible if the stroke is 0
        } else {
          strokes.width[i] = 0;
        }
      }
      
      for (let i = 0; i < dataLen; i++) {
        timeLabels.push(new Date(results[0].data[i].timestamp).
          toLocaleDateString("en", constants.timeFormat));
        for (let j = 0; j < results.length - 1; j++) {
          series[j].data.push(results[j].data[i].value.toFixed(2));
        }
        series[results.length - 1].data.push(results[results.length - 1].data[dataLen - i - 1].moer.toFixed(2)) // emission data
      }

      this.options = {
        labels: timeLabels,
        legend: {
          position: "bottom",
        },
        stroke: strokes,
        series: series,
        
        plotOptions: {
          bar: {
            columnWidth: "50%",
          },
        },
        fill: {
          opacity: [0.85, 0.25, 1],
          gradient: {
            inverseColors: false,
            shade: "light",
            type: "vertical",
            opacityFrom: 0.85,
            opacityTo: 0.55,
            stops: [0, 100, 100, 100],
          },
        },
        labels: timeLabels,
        yaxis: [
          {
            title: {
              text: "Average Power (kW)",
            },
            seriesName: "Battery Charging (kW)",
          },
          {
            seriesName: "Battery Charging (kW)",
            show: false
          },
          {
            seriesName: "Battery Charging (kW)",
            show: false
          },
          {
            seriesName: "Battery Charging (kW)",
            show: false
          },
          {
            seriesName: "Battery Charging (kW)",
            show: false
          },
          {
            seriesName: "Battery Charging (kW)",
            show: false
          },
          {
            seriesName: "Battery Charging (kW)",
            show: false
          },
          {
            title: {
              text: "Emission (kgCO2/kWh)",
            },
            seriesName: "Emission (kgCO2/kWh)",
            opposite: true
          }
        ],
        legend: {
          position: "bottom",
        }
      };

      this.$refs.multiAxesChart.updateOptions(this.options, true);
      this.loaded = true;
    },
    timeStampToFormattedString(timestamp) {
      const date = new Date(timestamp);
      const year = date.getFullYear();
    }
  },
};
</script>