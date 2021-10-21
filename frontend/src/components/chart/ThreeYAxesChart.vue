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
  name: "ThreeYAxesChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    labels: Array,
    request: String
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
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.updateChart(data.results);
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
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
    labels: {
      immediate: true,
      handler() {
        document.labels = this.labels;
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
      constants: constants
    };
  },
  methods: {
    updateChart(results) {
      if (!results || results.length != 3) {
        return;
      }

      let timeLabels = [], series1 = [], series2 = [], series3 = [];
      for (let i = 0; i < results[0].data.length; i++) {
        timeLabels.push(new Date(results[0].data[i].timestamp).
          toLocaleDateString("en", constants.timeFormat));
        series1.push((results[0].data[i].value).toFixed(3));
        series2.push((results[1].data[i].value).toFixed(3));
        series3.push((results[2].data[i].value).toFixed(3));
      }
      
      let strokes = {};
      if (this.leftAxisType == constants.chartTypes.Column) {
        strokes = {
          width: [0, 4, 4],
        }; // line is not visible if the stroke is 0
      }

      this.options = {
        chart: {
          height: 350,
          type: "line",
          stacked: false,
        },
        series: [
          {
            name: this.labels[0],
            type: "column",
            data: series1,
          },
          {
            name: this.labels[1],
            type: "area",
            data: series2,
          },
          {
            name: this.labels[2],
            type: "line",
            data: series3,
          }
        ],
        stroke: {
          width: [0, 2, 5],
          curve: "smooth",
        },
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
        yaxis: {
          title: {
            text: "Average Power (kW)",
          },
          min: 0,
        },
        legend: {
          position: "bottom",
        }
      };

      this.$refs.multiAxesChart.updateOptions(this.options, true);
      this.loaded = true;
    },
  },
};
</script>