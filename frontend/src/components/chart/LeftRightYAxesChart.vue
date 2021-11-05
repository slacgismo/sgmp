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

// blue, orange, green
const colors = ["#008FFB", "#00E396", "#FEB019"];

export default {
  name: "LeftRightYAxesChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    leftAxisTitle: String,
    leftAxisType: String,
    rightAxis1Title: String,
    rightAxis2Title: String,
    axes: Object,
    request: Object
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
        this.fetchData();
      },
    },
    axes: {
      immediate: true,
      handler() {
        document.axes = this.axes;
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
      if (!results || results.length < 1) {
        this.loaded = true;
        return;
      }

      let timeLabels = [], series = [], yAxes = [], strokes = { width: []};
      for (let i = 0; i < results.length; i++) {
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

        yAxes[i] = {
          axisTicks: {
            show: true,
          },
          axisBorder: {
            show: true,
            color: colors[i],
          },
          labels: {
            style: {
              colors: colors[i],
            },
          },
          title: {
            text: this.axes[i].title,
            style: {
              color: colors[i],
            },
          },
        };
        if (results.length > 1 && i > 0) {
          yAxes[i].opposite = true;
        }
        if (results.length > 2 && i == 0) {
          yAxes[i].forceNiceScale = false;
          yAxes[i].min = 0;
          yAxes[i].max = 100;
          yAxes[i].tickAmount = 4;
        }
      }
      
      for (let i = 0; i < results[0].data.length; i++) {
        timeLabels.push(new Date(results[0].data[i].timestamp).
          toLocaleDateString("en", constants.timeFormat));
        for (let j = 0; j < results.length; j++) {
          series[j].data.push(results[j].data[i].value.toFixed(3));
        }
      }

      this.options = {
        labels: timeLabels,
        legend: {
          position: "bottom",
        },
        stroke: strokes,
        series: series,
        yaxis: yAxes
      };

      this.$refs.leftRightAxesChart.updateOptions(this.options, true);
      this.loaded = true;
    },
    fetchData() {
      if (!this.request) {
        return;
      }
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
    }
  }
};
</script>