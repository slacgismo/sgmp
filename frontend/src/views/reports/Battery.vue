<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <div class="flex items-center">
      <!-- https://www.svgrepo.com/svg/326915/battery-charging-sharp -->
      <img src="/src/assets/img/battery.svg" class="h-12 w-12" />
      <h2 class="px-4 text-xl text-gray-400">Reports / <span class="text-xl text-gray-600">Battery</span></h2>
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
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-8">
          <!-- https://www.svgrepo.com/svg/89155/battery -->
          <analytic-card :isPower="true" :title="CHARGING" img="charging.svg" 
           :period="getPeriod(State.Day)" :request="getAggRequest(State.Day, 'avg')" />
          <analytic-card :isPower="true" :title="DISCHARGING" img="discharging.svg"
           :period="getPeriod(State.Day)" :request="getAggRequest(State.Day, 'avg')" />
          <!-- https://www.svgrepo.com/svg/285729/award-champion -->
          <analytic-card :isPower="false" :title="HIGH"
            img="champion.svg" :request="getAggRequest(State.Day, 'max')" />
          <!-- https://www.svgrepo.com/svg/125860/down-arrow -->
          <analytic-card :isPower="false" :title="LOW" img="down-arrow.svg"
           :request="getAggRequest(State.Day, 'min')" />
        </div>
        <three-y-axes-chart :title="TITLE"
          leftAxisTitle="SOC (%)" rightAxis1Title="Average Power (kW)"
          rightAxis2Title="Cumulative Energy (kWh)" request="" />
      </tab>

      <tab title="Last 7 days">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-8">
          <analytic-card :isPower="true" :title="CHARGING" img="charging.svg" 
           :period="getPeriod(State.Week)" :request="getAggRequest(State.Week, 'avg')" />
          <analytic-card :isPower="true" :title="DISCHARGING" img="discharging.svg"
           :period="getPeriod(State.Week)" :request="getAggRequest(State.Week, 'avg')" />
          <analytic-card :isPower="false" :title="HIGH"
            img="champion.svg" :request="getAggRequest(State.Week, 'max')" />
          <analytic-card :isPower="false" :title="LOW" img="energy.svg"
           :request="getAggRequest(State.Week, 'min')" />
        </div>
        <!-- <line-column-chart title="Solar Generation" :request="getTSRequest(State.Day)"/> -->
      </tab>
      
      <tab :title="getCurrentMonth()">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-8">
          <analytic-card :isPower="true" :title="CHARGING" img="charging.svg" 
           :period="getPeriod(State.Month)" :request="getAggRequest(State.Month, 'avg')" />
          <analytic-card :isPower="true" :title="DISCHARGING" img="discharging.svg"
           :period="getPeriod(State.Month)" :request="getAggRequest(State.Month, 'avg')" />
          <analytic-card :isPower="false" :title="HIGH"
            img="champion.svg" :request="getAggRequest(State.Month, 'max')" />
          <analytic-card :isPower="false" :title="LOW" img="energy.svg"
           :request="getAggRequest(State.Month, 'min')" />
        </div>
        <!-- <line-column-chart title="Solar Generation" :request="getTSRequest(State.Day)"/> -->
      </tab>
    </tabs>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import Tabs from "@/components/tab/Tabs.vue";
import Tab from "@/components/tab/Tab.vue";
import ThreeYAxesChart from "@/components/chart/ThreeYAxesChart.vue";
import AnalyticCard from '@/components/card/AnalyticCard.vue';
import { ref } from "vue";
const State = Object.freeze({ Day: 0, Week: 1, Month: 2 });
const CHARGING = "Average Charging";
const DISCHARGING = "Average Discharging";
const HIGH = "Highest State Of Charge (SOC)";
const LOW = "Lowest State Of Charge (SOC)";
const TITLE = "Battery Power, Energy and State Of Charge (SOC)";
const now = new Date();

export default {
  components: { apexchart: VueApexCharts, Tabs, Tab, ThreeYAxesChart, AnalyticCard },
  setup() {
    const active = ref(0);
    return {
      active,
    };
  },
  data() {
    return {
      State,
      CHARGING,
      DISCHARGING,
      HIGH,
      LOW,
      TITLE,
      now
    }
  },
  methods: {
    getCurrentMonth() {
      return `${now.toLocaleDateString("en", {month: "long"})}`;
    },
    getPeriod(type) {
      const format = {month: "short", day:"numeric", hour: "numeric", minute:"numeric"};
      let start = new Date(this.getStartTime(now, type));
      return `${start.toLocaleDateString("en", format) +
        ` ~\n` + now.toLocaleDateString("en", format)}`;
    },
    getTSRequest(type) {
      return {
        "start_time": this.getStartTime(now, type),
        "end_time": now.getTime(),
        "type": "analytics",
        "analytics_id": 2
      };
    },
    getAggRequest(type, aggFunc) {
      return {
        "start_time": this.getStartTime(now, type),
        "end_time": now.getTime(),
        "type": "analytics",
        "agg_function": aggFunc,
        "formula": "sonnen.status.Production_W"
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
        default:  // default is today
          start = cur - 86400000; // 1000 * 3600 * 24 = 86400000
      }
      return start;
    }
  }
};
</script>
