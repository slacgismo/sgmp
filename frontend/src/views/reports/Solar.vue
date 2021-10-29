<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <div class="flex items-center">
      <!-- https://uxwing.com/solar-energy-icon/ -->
      <img src="/src/assets/img/sun.svg" class="h-12 w-12" />

      <h2 class="px-4 text-xl text-gray-400">Reports / <span class="text-xl text-gray-600">Solar</span></h2>
      <!-- <div class="px-4">
        <h2 class="text-xl text-gray-400">Reports / </h2>
        <h2 class="text-xl text-gray-600">Solar</h2>
      </div> -->
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
          <!-- https://www.svgrepo.com/svg/285729/award-champion -->
          <analytic-card :unit="constants.units.Power" :title="PEAK"
            img="champion.svg" :request="getAggRequest(State.Day, 'max')" />
          <!-- https://www.svgrepo.com/svg/270552/renewable-energy-power -->
          <analytic-card :unit="constants.units.Energy" :title="AVG" img="energy.svg"
           :request="getAggRequest(State.Day, 'avg')" :period="getPeriod(State.Day)" />
        </div>
        <line-column-chart :title="TITLE" :request="getTSRequest(State.Day)"/>
      </tab>

      <tab title="Last 7 days">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <analytic-card :unit="constants.units.Power" :title="PEAK"
            img="champion.svg" :request="getAggRequest(State.Week, 'max')" />
          <analytic-card :unit="constants.units.Energy" :title="AVG" img="energy.svg"
           :request="getAggRequest(State.Week, 'avg')" :period="getPeriod(State.Week)" />
        </div>
        <line-column-chart :title="TITLE" :request="getTSRequest(State.Week)"/>
      </tab>
      
      <tab :title="getCurrentMonth()">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <analytic-card :unit="constants.units.Power" :title="PEAK"
            img="champion.svg" :request="getAggRequest(State.Month, 'max')" />
          <analytic-card :unit="constants.units.Energy" :title="AVG" img="energy.svg"
           :request="getAggRequest(State.Month, 'avg')" :period="getPeriod(State.Month)" />
        </div>
        <line-column-chart :title="TITLE" :request="getTSRequest(State.Month)"/>
      </tab>
    </tabs>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Tabs from "@/components/tab/Tabs.vue";
import Tab from "@/components/tab/Tab.vue";
import LineColumnChart from "@/components/chart/LineColumnChart.vue";
import AnalyticCard from '@/components/card/AnalyticCard.vue';
import constants from '@/util/constants';
import { ref } from "vue";
const State = Object.freeze({ Day: 0, Week: 1, Month: 2 });
const PEAK = "Peak Solar Production";
const AVG = "Average Energy Generation";
const TITLE = "Solar Generation";
const now = new Date();

export default {
  components: { apexchart: VueApexCharts, Tabs, Tab, LineColumnChart, AnalyticCard },
  setup() {
    const active = ref(0);
    return {
      active,
    };
  },
  data() {
    return {
      State,
      PEAK,
      AVG,
      TITLE,
      now,
      constants
    }
  },
  methods: {
    getCurrentMonth() {
      return `${now.toLocaleDateString("en", {month: "long"})}`;
    },
    getPeriod(type) {
      let start = new Date(this.getStartTime(now, type));
      return `${start.toLocaleDateString("en", constants.timeFormat) +
        ` ~\n` + now.toLocaleDateString("en", constants.timeFormat)}`;
    },
    getTSRequest(type) {
      let ret = {
        start_time: this.getStartTime(now, type),
        end_time: now.getTime(),
        type: "analytics",
        analytics_name: constants.formula.Solar,
        house_id: localStorage.getItem("house_id")
      };
      // Weekly and montly data are by default averaged over 1 hour
      if (type == State.Day) {
        ret['average'] = 300000; // 5 min
        ret['fine'] = true;
      }
      return ret;
    },
    getAggRequest(type, aggFunc) {
      let ret = {
        start_time: this.getStartTime(now, type),
        end_time: now.getTime(),
        type: "analytics",
        agg_function: aggFunc,
        analytics_name: constants.formula.Solar,
        house_id: localStorage.getItem("house_id")
      };
      if (type == State.Day) {
        // We want fine-grained data
        ret['fine'] = true;
      }
      return ret;
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
        default:  // default is today
          start = cur - 86400000; // 1000 * 3600 * 24 = 86400000
      }
      return start;
    }
  }
};
</script>
