<template>
  <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
    <h3 class="text-xl text-gray-600 mb-4">{{ title }}</h3>
    <div>
      <loading v-show="!loaded" />
      <apexchart
        v-show="loaded"
        ref="multiAxesChart"
        type="line"
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
// to be replaced with real data
import frequency from "@/data/home/frequency.json";
import voltage from "@/data/home/voltage.json";

const colorBlue = "#008FFB";
const colorOrange = "#00E396";
const colorGreen = "#FEB019";

export default {
  name: "ThreeYAxesChart",
  components: { apexchart: VueApexCharts, Loading },
  props: {
    title: String,
    leftAxisTitle: String,
    rightAxis1Title: String,
    rightAxis2Title: String,
    request: String,
  },
  mounted() {
    // POST request to fetch data for the 3 y-axis chart
    let requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: // this.request
      JSON.stringify({
        "start_time": new Date().getTime()-3600000,
        "end_time": new Date().getTime(),
        "type": "device",
        "device_id": 2
      })
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

        this.updateChart(frequency);
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
    };
  },
  methods: {
    updateChart(data) {
      if (!data) {
        return;
      }

      // let timeLabels = [], leftSeries = [], right1Series = [], right2Series = []
      // let cumulativeEnergy = 0;
      // for (let i = 0; i < data.length; i++) {
      //   timeLabels.push(new Date(data[i].timestamp).
      //     toLocaleDateString("en", {month: "short", day:"numeric", hour: "numeric", minute:"numeric"}))
      //   leftSeries.push((data[i].value / 1000).toFixed(2)) // W = 1/1000 kW
      //   cumulativeEnergy += (data[i].value / 12000) // interval 5 min = 1/12 h, W = 1/1000 kW
      //   right1Series.push(cumulativeEnergy.toFixed(2))
      // }
      // right2Series = leftSeries;  // TODO

      const format = {
        month: "short",
        day: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      };
      let timeLabels = [],
        leftSeries = [],
        right1Series = [],
        right2Series = [];
      for (let i = 0; i < data.length; i++) {
        timeLabels.push(
          new Date(data[i].timestamp).toLocaleTimeString("en", format)
        );
        leftSeries.push(data[i].data);
        right1Series.push(voltage[i].data);
        right2Series.push(voltage[i].data);
      }

      this.options = {
        labels: timeLabels,
        legend: {
          position: "bottom",
        },
        series: [
          {
            name: this.leftAxisTitle,
            type: "column",
            data: leftSeries,
          },
          {
            name: this.rightAxis1Title,
            type: "line",
            data: right1Series,
          },
          {
            name: this.rightAxis2Title,
            type: "line",
            data: right2Series,
          },
        ],
        yaxis: [
          {
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

      this.$refs.multiAxesChart.updateOptions(this.options, true);
      this.loaded = true;
    },
  },
};
</script>