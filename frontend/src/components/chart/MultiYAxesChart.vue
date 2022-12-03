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
    // GET request to login to CAISO
    fetch(
        constants.caiso.server + "/login", {
          method: "GET",
          headers: { 
            "Content-Type": "application/json",
            "Authorization": "Basic " + btoa(constants.caiso.username + ":" + constants.caiso.password)
          }
        }
      )
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok || !data.token) {
          // get error message from body or default to response status
          const error = response.status;
          return Promise.reject(error);
        }

        const token = data.token;
        const now = new Date();
        const startTime =  now.getTime() - 86800000;
        const endTime = now.getTime();

        const emission = fetch(
           "https://cors-anywhere.herokuapp.com/" + 
          constants.caiso.server + "/sgipmoer?" + 
          "ba=" + constants.caiso.ba + 
          "&version=" + constants.caiso.moerVersion + 
          "&starttime=" + new Date(startTime).toISOString() +
          "&endtime=" + new Date(endTime).toISOString(), {
            method: "GET",
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer " + token  
            }
          }
        );

        const power = fetch(
          constants.server + "/api/data/read", // endpoint
          httpReq.post(this.request) // requestOptions
        );

        console.log(emission)

        return Promise.all([emission, power]);
      })
      .then(async ([emissionResponse, powerResponse]) => {
        const emission = await emissionResponse.json();
        const power = await powerResponse.json();

        console.log(emission);
        console.log(power);

        // check for error response
        // if (!powerResponse.ok || !powerResponse.results) {
        //   // get error message from body or default to response status
        //   const error = (power && power.message) || powerResponse.status;
        //   return Promise.reject(error);
        // }

        this.updateChart(emission, power.results);
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
    updateChart(emission, power) {
      // unified lengths of all 
      var dataLen = emission.length;
      for (let i = 0; i < power.length; i++) {
        dataLen = Math.min(dataLen, power[i].data.length);
      }

      if (!power || power.length < 1) {
        this.loaded = true;
        return;
      }

      let timeLabels = [], series = [], strokes = { width: []};
      for (let i = 0; i < power.length; i++) {
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
      series[power.length] = {
        name: "Emission (kgCO2/kWh)",
        type: constants.chartTypes.Line,
        data: []
      }
      strokes.width[power.length] = 4;
      
      for (let i = 0; i < dataLen; i++) {
        timeLabels.push(new Date(power[0].data[i].timestamp).
          toLocaleDateString("en", constants.timeFormat));
        for (let j = 0; j < power.length; j++) {
          series[j].data.push(power[j].data[i].value.toFixed(2));
        }
        series[power.length].data.push(emission[dataLen - i - 1].moer.toFixed(2))
      }

      console.log(series)

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
            seriesName: "Solar (kW)",
            min: 0,
          },
          {
            seriesName: "Solar (kW)",
            show: false
          },
          {
            seriesName: "Solar (kW)",
            show: false
          },
          {
            seriesName: "Solar (kW)",
            show: false
          },
          {
            seriesName: "Solar (kW)",
            show: false
          },
          {
            seriesName: "Solar (kW)",
            show: false
          },
          {
            seriesName: "Solar (kW)",
            show: false
          },
          {
            title: {
              text: "Emission (kgCO2/kWh)",
            },
            seriesName: "Emission (kgCO2/kWh)",
            min: 0,
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