<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <div class="flex items-center">
        <!-- Credit: modified from https://www.svgrepo.com/svg/137351/rounded-plug -->
      <img src="/src/assets/img/load.svg" class="h-12 w-12" />

      <h2 class="px-4 text-xl text-gray-400">
        Reports / <span class="text-xl text-gray-600">Load</span>
      </h2>
    </div>
    <div class="flex items-center space-x-1 text-xs">
      <router-link to="/" class="font-bold text-indigo-700">Home</router-link>
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
      <span class="text-gray-600">Reports</span>
    </div>
  </div>
  <div class="px-4 mt-8 sm:px-8">
    <tabs v-model="active">
      <tab title="Last 24 hours">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <!-- https://www.svgrepo.com/svg/193927/power-button -->
          <analytic-card
            :isPower="true"
            :title="POWER"
            img="power.svg"
            :request="getAggRequest(State.Day, 'avg')"
            :period="getPeriod(State.Day)"
          />
          <!-- https://www.svgrepo.com/svg/270552/renewable-energy-power -->
          <analytic-card
            :isPower="false"
            :title="ENERGY"
            img="energy.svg"
            :request="getAggRequest(State.Day, 'avg')"
            :period="getPeriod(State.Day)"
          />
        </div>
        <line-column-chart
          :title="TITLE"
          :request="getTSRequest(State.Day)"
        />
      </tab>

      <tab title="Last 7 days">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <analytic-card
            :isPower="true"
            :title="POWER"
            img="power.svg"
            :request="getAggRequest(State.Week, 'avg')"
            :period="getPeriod(State.Day)"
          />
          <analytic-card
            :isPower="false"
            :title="ENERGY"
            img="energy.svg"
            :request="getAggRequest(State.Week, 'avg')"
            :period="getPeriod(State.Week)"
          />
        </div>
        <line-column-chart
          :title="TITLE"
          :request="getTSRequest(State.Week)"
        />
      </tab>

      <tab :title="getCurrentMonth()">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <analytic-card
            :isPower="true"
            :title="POWER"
            img="power.svg"
            :request="getAggRequest(State.Month, 'avg')"
            :period="getPeriod(State.Day)"
          />
          <analytic-card
            :isPower="false"
            :title="ENERGY"
            img="energy.svg"
            :request="getAggRequest(State.Month, 'avg')"
            :period="getPeriod(State.Month)"
          />
        </div>
        <line-column-chart
          :title="TITLE"
          :request="getTSRequest(State.Month)"
        />
      </tab>
    </tabs>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Tabs from "@/components/tab/Tabs.vue";
import Tab from "@/components/tab/Tab.vue";
import LineColumnChart from "@/components/chart/LineColumnChart.vue";
import AnalyticCard from "@/components/card/AnalyticCard.vue";
import { ref } from "vue";
const State = Object.freeze({ Day: 0, Week: 1, Month: 2 });
const POWER = "Average Power Consumption";
const ENERGY = "Average Energy Consumption";
const TITLE = "Load Consumption";
const now = new Date();

export default {
  components: {
    apexchart: VueApexCharts,
    Tabs,
    Tab,
    LineColumnChart,
    AnalyticCard,
  },
  setup() {
    const active = ref(0);
    return {
      active,
    };
  },
  data() {
    return {
      State,
      POWER,
      ENERGY,
      TITLE,
      now,
    };
  },
  methods: {
    getCurrentMonth() {
      return `${now.toLocaleDateString("en", { month: "long" })}`;
    },
    getPeriod(type) {
      const format = {
        month: "short",
        day: "numeric",
        hour: "numeric",
        minute: "numeric",
      };
      let start = new Date(this.getStartTime(now, type));
      return `${
        start.toLocaleDateString("en", format) +
        ` ~\n` +
        now.toLocaleDateString("en", format)
      }`;
    },
    getTSRequest(type) {
      let interval = 3600000; // 1 hour = 60 * 60 * 1000
      if (type == State.Day) {
        interval = 300000; // 5 min
      }
      return {
        "start_time": this.getStartTime(now, type),
        "end_time": now.getTime(),
        "type": "analytics",
        "average": interval,
        "formula": "sonnen.status.Consumption_W"
      };
    },
    getAggRequest(type, aggFunc) {
      return {
        "start_time": this.getStartTime(now, type),
        "end_time": now.getTime(),
        "type": "analytics",
        "agg_function": aggFunc,
        "formula": "sonnen.status.Consumption_W",
      };
    },
    getStartTime(now, type) {
      let cur = now.getTime();
      let start;
      switch (type) {
        case State.Month:
          start = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
          break;
        case State.Week:
          start = cur - 604800000; // 1000 * 3600 * 24 * 7 = 604800000
          break;
        default:
          // default is today
          start = cur - 86400000; // 1000 * 3600 * 24 = 86400000
      }
      return start;
    },
  },
};
</script>
