<template>
  <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
    <h3 class="text-xl text-gray-600 mb-4">{{ title }}</h3>
    <div>
      <loading v-show="!loaded" />
      <apexchart
        v-show="loaded"
        ref="leftRightAxesChart"
        :type="constants.chartTypes.Line"
        :height="300"
        :options="options"
        :series="series"
      />
    </div>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Loading from "@/components/Loading.vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

const colorBlue = "#008FFB";
const colorOrange = "#00E396";
const colorGreen = "#FEB019";

export default {
  name: "LeftRightYAxesChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    leftAxisTitle: String,
    leftAxisType: String,
    rightAxis1Title: String,
    rightAxis2Title: String,
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
    request: {
      immediate: true,
      handler() {
        document.request = this.request;
      },
    },
    leftAxisTitle: {
      immediate: true,
      handler() {
        document.leftAxisTitle = this.leftAxisTitle;
      },
    },
    leftAxisType: {
      immediate: true,
      handler() {
        document.leftAxisType = this.leftAxisType;
      },
    },
    rightAxis1Title: {
      immediate: true,
      handler() {
        document.rightAxis1Title = this.rightAxis1Title;
      },
    },
    rightAxis2Title: {
      immediate: true,
      handler() {
        document.rightAxis2Title = this.rightAxis2Title;
      },
    }
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

      let timeLabels = [], leftSeries = [], right1Series = [], right2Series = [];
      // let cumulativeEnergy = 0;
      for (let i = 0; i < results[0].data.length; i++) {
        timeLabels.push(new Date(results[0].data[i].timestamp).
          toLocaleDateString("en", constants.timeFormat));
        leftSeries.push((results[0].data[i].value).toFixed(3));
        right1Series.push((results[1].data[i].value).toFixed(3));
        right2Series.push((results[2].data[i].value).toFixed(3));
      }
      
      let strokes = {};
      if (this.leftAxisType == constants.chartTypes.Column) {
        strokes = {
          width: [0, 4, 4],
        }; // line is not visible if the stroke is 0
      }

      this.options = {
        labels: timeLabels,
        legend: {
          position: "bottom",
        },
        stroke: strokes,
        series: [
          {
            name: this.leftAxisTitle,
            type: this.leftAxisType,
            data: leftSeries,
          },
          {
            name: this.rightAxis1Title,
            type: constants.chartTypes.Line,
            data: right1Series,
          },
          {
            name: this.rightAxis2Title,
            type: constants.chartTypes.Line,
            data: right2Series,
          },
        ],
        yaxis: [
          {
            forceNiceScale: false,
            min: 0,
            max: 100,
            tickAmount: 4,
            axisTicks: {
              show: true,
            },
            axisBorder: {
              show: true,
              color: colorBlue,
            },
            labels: {
              style: {
                colors: colorBlue,
              },
            },
            title: {
              text: this.leftAxisTitle,
              style: {
                color: colorBlue,
              },
            },
            tooltip: {
              enabled: true,
            },
          },
          {
            opposite: true,
            axisTicks: {
              show: true,
            },
            axisBorder: {
              show: true,
              color: colorOrange,
            },
            labels: {
              style: {
                colors: colorOrange,
              },
            },
            title: {
              text: this.rightAxis1Title,
              style: {
                color: colorOrange,
              },
            },
          },
          {
            opposite: true,
            axisTicks: {
              show: true,
            },
            axisBorder: {
              show: true,
              color: colorGreen,
            },
            labels: {
              style: {
                colors: colorGreen,
              },
            },
            title: {
              text: this.rightAxis2Title,
              style: {
                color: colorGreen,
              },
            },
          },
        ],
      };

      this.$refs.leftRightAxesChart.updateOptions(this.options, true);
      this.loaded = true;
    },
  },
};
</script>