<template>
  <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
    <h3 class="text-xl text-gray-600 mb-4">{{ title }}</h3>
    <div>
      <loading v-show="!loaded" />
      <apexchart
        v-show="loaded"
        ref="donutChart"
        :type="constants.chartTypes.Donut"
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

export default {
  name: "DonutChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    labels: Array,
    request: String
  },
  mounted() {
    // POST request to fetch data for the donut chart
    fetch(
      constants.server + "/api/data/read", // endpoint
      httpReq.post(this.request) // requestOptions
    )
      .then(async (response) => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.updateChart(data.results);
      })
      .catch((error) => {
        this.errorMessage = error;
        console.error("There was an error!", error);
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
      },
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
    updateChart(data) {
      if (!data) {
        return;
      }
      let values = [];
      for (let i = 0; i < data.length; i++) {
        // round to 3 decimals
        if (!data[i].value) { // certain data might be unavailable
          values.push(0);
        } else {
          values.push(Math.round((data[i].value + Number.EPSILON) * 1000) / 1000);
        }
      }

      this.options = {
        labels: this.labels,
        series: values,
        legend: {
          position: "right",
        },
        tooltip: {
          shared: true,
          intersect: false,
          y: {
            formatter: function (y) {
              if (typeof y !== "undefined") {
                return y + " " + constants.units.Energy;
              }
              return y;
            },
          },
        },
      };

      this.$refs.donutChart.updateOptions(this.options, true);
      this.loaded = true;
    },
  },
};
</script>