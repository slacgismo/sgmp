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

  <div class="px-4 mt-4 sm:px-8">
    <div class="flex items-center bg-red-100 rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <!-- https://uxwing.com/emergency-icon/ -->
        <img src="/src/assets/img/outage.svg" class="h-6 w-6" />
      </div>
      <div>
        <h3 class="text-gray-700 font-bold">Outage:</h3>
        <p class="text-gray-700">xxx</p>
      </div>
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
        :request="getCardRequest(constants.analytics.Solar)"
      />
    </router-link>

    <router-link :to="{ name: 'battery' }">
      <!-- https://www.svgrepo.com/svg/326915/battery-charging-sharp -->
      <dashboard-card
        :unit="constants.units.Power"
        title="Battery Discharging"
        img="battery.svg"
        :request="getCardRequest(constants.analytics.Battery)"
      />
    </router-link>

    <router-link :to="{ name: 'ev' }">
      <!-- https://www.svgrepo.com/svg/17490/car -->
      <dashboard-card
        :unit="constants.units.Power"
        title="EV Charging"
        img="car.svg"
        :request="getCardRequest(constants.analytics.EV)"
      />
    </router-link>

    <router-link :to="{ name: 'load' }">
      <!-- Credit: modified from https://www.svgrepo.com/svg/137351/rounded-plug -->
      <dashboard-card
        :unit="constants.units.Power"
        title="Loads"
        img="load.svg"
        :request="getCardRequest(constants.analytics.Load)"
      />
    </router-link>
  </div>

  <div class="grid grid-cols-1 px-4 gap-4 mt-8 lg:grid-cols-2 sm:px-8">
    <donut-chart
      title="Energy Generation"
      :labels="['Grid', 'Battery', 'Solar']"
      :request="
        getDonutRequest([
          constants.analytics.Grid,
          constants.analytics.BatteryDischarging,
          constants.analytics.Solar,
        ])
      "
    />

    <three-y-axes-chart
      title="Power Consumption"
      :labels="['Load (kW)', 'EV (kW)', 'Battery (kW)']"
      :request="
        getTSRequest([
          constants.analytics.Load,
          constants.analytics.EV,
          constants.analytics.BatteryCharging,
        ])
      "
    />
  </div>

  <div class="grid grid-cols-1 px-4 gap-4 mt-8 sm:px-8">
    <left-right-y-axes-chart
      title="Grid Frequency and Voltage"
      :axes="axes"
      :request="getTSRequest([
        constants.analytics.Frequency,
        constants.analytics.Voltage1,
        constants.analytics.Voltage2,
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
      axes: [
        {title: "Grid frequency (Hz)", type: constants.chartTypes.Line},
        {title: "L1 Voltage (V)", type: constants.chartTypes.Line},
        {title: "L1 Voltage (V)", type: constants.chartTypes.Line}
      ]
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
        analytics_name: formula,
        fine: true,
        house_id: localStorage.getItem("house_id")
      };
    },
    getDonutRequest(formulae) {
      const start = new Date().setHours(0, 0, 0, 0);
      const duration = now.getTime() - start;
      let power2Energy = [];
      for (let i = 0; i < formulae.length; i++) {
        // kWh = kW * duration in ms / (60 * 60 * 1000)
        power2Energy.push("analytics." + formulae[i] + "/3600000*" + duration);
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
        analytics_name: formula,
        fine: true,
        average: 300000, // 5 minute = 5 * 60 * 1000
        house_id: localStorage.getItem("house_id")
      };
    },
  },
};
</script>