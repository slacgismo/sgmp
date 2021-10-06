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
          <analytic-card title="Peak Solar Production" img="champion.svg"
           value="4 kW" :time="getTime()" />
          <!-- https://www.svgrepo.com/svg/165281/medium -->
          <analytic-card title="Average Energy Generation" img="medium.svg"
           value="16 kWh" :time="getDate()" />
        </div>

        <line-column-chart title="Solar Generation"/>
      </tab>
      <tab title="Last 7 days">Week</tab>
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

export default {
  components: { apexchart: VueApexCharts, Tabs, Tab, LineColumnChart, AnalyticCard },
  setup() {
    const active = ref(1);
    return {
      active,
    };
  },
  methods: {
    getCurrentMonth() {
      return `${new Date().toLocaleDateString("en", {month: "long"})}`;
    },
    getDate() {
      return `${new Date().toLocaleDateString("en", {month: "short", day:"numeric"})}`;
    },
    getTime() {
      // var d = new Date();
      // let date = d.toLocaleDateString("en", {month: "short", day:"numeric"});
      // let time = d.toLocaleTimeString("en", {hour: "numeric", minute:"numeric"});
      // return `${date + "\n" + time}`;
      return `${new Date().toLocaleTimeString("en", {hour: "numeric", minute:"numeric"})}`;
    }
  }
};
</script>
