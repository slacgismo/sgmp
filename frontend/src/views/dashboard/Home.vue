<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-xl text-gray-600">
      {{ "Today's Dashboard : " + getDate() }}
    </h2>

    <div class="flex items-center space-x-1 text-xs">
      <a href="#" class="font-bold text-indigo-700">Home</a>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-2 w-2"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M9 5l7 7-7 7"
        />
      </svg>
      <span class="text-gray-600">Dashboard</span>
    </div>
  </div>

  <div
    class="
      grid grid-cols-1
      gap-4
      px-4
      mt-8
      lg:grid-cols-2
      xl:grid-cols-4
      sm:px-8
    "
  >
    <router-link :to="{ name: 'solar' }">
      <!-- https://uxwing.com/solar-energy-icon/ -->
      <dashboard-card
        :unit="constants.units.Power"
        title="Solar Power"
        img="sun.svg"
        :request="getCardRequest(constants.formula.Solar)"
      />
    </router-link>

    <router-link v-if="visible" :to="{ name: 'battery' }">
      <!-- https://www.svgrepo.com/svg/326915/battery-charging-sharp -->
      <dashboard-card
        :unit="constants.units.Power"
        title="Battery Discharging"
        img="battery.svg"
        :request="getCardRequest(constants.formula.Battery)"
      />
    </router-link>

    <router-link :to="{ name: 'ev' }">
      <!-- https://www.svgrepo.com/svg/17490/car -->
      <dashboard-card
        :unit="constants.units.Power"
        title="EV Charging"
        img="car.svg"
        :request="getCardRequest(constants.formula.EV)"
      />
    </router-link>

    <router-link :to="{ name: 'load' }">
      <!-- Credit: modified from https://www.svgrepo.com/svg/137351/rounded-plug -->
      <dashboard-card
        :unit="constants.units.Power"
        title="Loads"
        img="load.svg"
        :request="getCardRequest(constants.formula.Load)"
      />
    </router-link>
  </div>

  <div class="grid grid-cols-1 px-4 gap-4 mt-8 lg:grid-cols-2 sm:px-8">
    <donut-chart
      title="Energy Generation"
      :labels="['Grid', 'Battery', 'Solar']"
      :request="
        getDonutRequest([
          constants.formula.Grid,
          constants.formula.BatteryDischarging,
          constants.formula.Solar,
        ])
      "
    />

    <three-y-axes-chart
      title="Power Consumption"
      :labels="['Load (kW)', 'EV (kW)', 'Battery (kW)']"
      :request="
        getTSRequest([
          constants.formula.Load,
          constants.formula.EV,
          constants.formula.BatteryCharging,
        ])
      "
    />
  </div>

  <div class="grid grid-cols-1 px-4 gap-4 mt-8 sm:px-8">
    <left-right-y-axes-chart
      title="Grid Frequency and Voltage"
      leftAxisTitle="Grid frequency (Hz)"
      :leftAxisType="constants.chartTypes.Line"
      rightAxis1Title="L1 Voltage (V)"
      rightAxis2Title="L2 Voltage (V)"
      :request="getTSRequest([
        constants.formula.Frequency,
        constants.formula.Voltage1,
        constants.formula.Voltage2,
      ])"
    />
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import DashboardCard from "@/components/card/DashboardCard.vue";
import DonutChart from "@/components/chart/DonutChart.vue";
import LeftRightYAxesChart from "@/components/chart/LeftRightYAxesChart.vue";
import ThreeYAxesChart from "@/components/chart/ThreeYAxesChart.vue";
import constants from "@/util/constants";
import httpReq from "@/util/requestOptions";
const now = new Date();

export default {
  components: {
    apexchart: VueApexCharts,
    DashboardCard,
    DonutChart,
    LeftRightYAxesChart,
    ThreeYAxesChart
  },
  data() {
    return {
      now,
      constants,
      visible: false
    };
  },
  created() {
    // POST request to fetch data for the houses
    fetch(
      constants.server + "/api/device/list", // endpoint
      httpReq.post({"house_id": localStorage.getItem("house_id")}) // requestOptions
    )
      .then(async (response) => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        if (data && data.devices) {
          for (let i = 0; i < data.devices.length; i++) {
            if (data.devices[i].type == constants.sources.Battery) {
              this.visible = true;
            }
          }
        }
      })
      .catch((error) => {
        this.errorMessage = error;
        console.error(error);
      });
  },
  methods: {
    getDate() {
      const format = {
        year: "numeric",
        month: "short",
        day: "numeric",
      };
      return `${new Date().toLocaleDateString("en", format)}`;
    },
    // TODO: update when the backend API is ready to fetch current data
    getCardRequest(formula) {
      return {
        start_time: now.getTime() - 20000, // 20 s
        end_time: now.getTime(),
        type: "analytics",
        agg_function: "max",
        formula: formula,
        house_id: localStorage.getItem("house_id")
      };
    },
    getDonutRequest(formulae) {
      const start = new Date().setHours(0, 0, 0, 0);
      const duration = now.getTime() - start;
      let power2Energy = [];
      for (let i = 0; i < formulae.length; i++) {
        // kWh = kW * duration in ms / (60 * 60 * 1000)
        power2Energy.push(formulae[i] + "/3600000*" + duration);
      }

      return {
        // start from the beginning of the day
        start_time: start,
        end_time: now.getTime(),
        type: "analytics",
        agg_function: "avg",
        formula: power2Energy,
        house_id: localStorage.getItem("house_id")
      };
    },
    getTSRequest(formula) {
      return {
        // last 24 hours: 24 * 60 * 60 * 1000
        start_time: now.getTime() - 86400000,
        end_time: now.getTime(),
        type: "analytics",
        formula: formula,
        average: 300000, // 5 minute = 5 * 60 * 1000
        house_id: localStorage.getItem("house_id")
      };
    },
  },
};
</script>