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
          <analytic-card :isPower="true" title="Peak Solar Production" 
            img="champion.svg" :request="getAggRequest(State.Day, 'max')" />
          <!-- https://www.svgrepo.com/svg/165281/medium -->
          <analytic-card :isPower="false" title="Average Energy Generation" img="medium.svg"
           :request="getAggRequest(State.Day, 'avg')" :date="getDate()" />
        </div>
        <line-column-chart title="Solar Generation" :request="getTSRequest()"/>
      </tab>

      <tab title="Last 7 days">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <analytic-card :isPower="true" title="Peak Solar Production" 
            img="champion.svg" :request="getAggRequest(State.Week, 'max')" />
          <analytic-card :isPower="false" title="Average Energy Generation" img="medium.svg"
           :request="getAggRequest(State.Week, 'avg')" :date="getDate()" />
        </div>
        <line-column-chart title="Solar Generation" :request="getTSRequest()"/>
      </tab>
      
      <tab :title="getCurrentMonth()">Month</tab>
    </tabs>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Tabs from "@/components/tab/Tabs.vue";
import Tab from "@/components/tab/Tab.vue";
import LineColumnChart from "@/components/chart/LineColumnChart.vue";
import AnalyticCard from '@/components/card/AnalyticCard.vue';
import { ref } from "vue";
const State = Object.freeze({ Day: 0, Week: 1, Month: 2 });

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
      State
    }
  },
  methods: {
    getCurrentMonth() {
      return `${new Date().toLocaleDateString("en", {month: "long"})}`;
    },
    getDate() {
      return `${new Date().toLocaleDateString("en", {month: "short", day:"numeric"})}`;
    },
    getTSRequest() {
      const now = new Date().getTime();
      return JSON.stringify({
        "start_time": now - 3600000, // 1000 * 3600 * 24 = 86400000
        "end_time": now,
        "type": "analytics",
        "analytics_id": 2
      });
    },
    getAggRequest(type, aggFunc) {
      const now = new Date().getTime();
      let start;
      switch (type) {
        case State.Month:
          start = new Date(now.getFullYear(), now.getMonth(), 1).getTime();
          break;
        case State.Week:
          start = now - 3600000; // 1000 * 3600 * 24 * 7 = 604800000
          break;
        default:  // default is today
          start = now - 3600000; // 1000 * 3600 * 24 = 86400000
      }

      return JSON.stringify({
        "start_time": start,
        "end_time": now,
        "type": "analytics",
        "agg_function": aggFunc,
        "formula": "sonnen.status.Production_W"
      });
    }
  }
};
</script>
