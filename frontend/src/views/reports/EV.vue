<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <div class="flex items-center">
      <!-- https://www.svgrepo.com/svg/17490/car -->
      <img src="/src/assets/img/car.svg" class="h-12 w-12" />

      <h2 class="px-4 text-xl text-gray-400">
        Reports / <span class="text-xl text-gray-600">Electric Vehicle</span>
      </h2>
    </div>
    <navigation-bar plainText="Reports" />
  </div>
  <div class="px-4 mt-8 sm:px-8">
    <tabs v-model="active">
      <tab title="Last 24 hours">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <!-- https://www.svgrepo.com/svg/193927/power-button -->
          <analytic-card
            :unit="constants.units.Power"
            :title="POWER"
            img="power.svg"
            :request="getAggRequest(State.Day, 'avg', constants.analytics.EV)"
            :period="getPeriod(State.Day)"
          />
          <!-- https://www.svgrepo.com/svg/270552/renewable-energy-power -->
          <analytic-card
            :unit="constants.units.Energy"
            :title="ENERGY"
            img="energy.svg"
            :request="getAggRequest(State.Day, 'avg', constants.analytics.EV)"
            :period="getPeriod(State.Day)"
          />
          <!-- https://www.svgrepo.com/svg/310384/book-number -->
          <analytic-card
            :unit="constants.units.Number"
            :title="NUMBER"
            img="number.svg"
            :request="getAggRequest(State.Day, 'count', constants.analytics.EVChargingCount)"
            :period="getPeriod(State.Day)"
          />
          <!-- https://www.svgrepo.com/svg/123236/time -->
          <analytic-card
            :unit="constants.units.Millisecond"
            :title="DURATION"
            img="time.svg"
            :request="getAggRequest(State.Day, 'avg', constants.analytics.EVChargingDuration)"
            :period="getPeriod(State.Day)"
          />
        </div>
        <line-column-chart :title="TITLE" :request="getTSRequest(State.Day)" />
      </tab>

      <tab title="Last 7 days">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <analytic-card
            :unit="constants.units.Power"
            :title="POWER"
            img="power.svg"
            :request="getAggRequest(State.Week, 'avg', constants.analytics.EV)"
            :period="getPeriod(State.Week)"
          />
          <analytic-card
            :unit="constants.units.Energy"
            :title="ENERGY"
            img="energy.svg"
            :request="getAggRequest(State.Week, 'avg', constants.analytics.EV)"
            :period="getPeriod(State.Week)"
          />
          <analytic-card
            :unit="constants.units.Number"
            :title="NUMBER"
            img="number.svg"
            :request="getAggRequest(State.Week, 'count', constants.analytics.EVChargingCount)"
            :period="getPeriod(State.Week)"
          />
          <analytic-card
            :unit="constants.units.Millisecond"
            :title="DURATION"
            img="time.svg"
            :request="getAggRequest(State.Week, 'avg', constants.analytics.EVChargingDuration)"
            :period="getPeriod(State.Week)"
          />
        </div>
        <line-column-chart :title="TITLE" :request="getTSRequest(State.Week)" />
      </tab>

      <tab :title="getCurrentMonth()">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mb-8">
          <analytic-card
            :unit="constants.units.Power"
            :title="POWER"
            img="power.svg"
            :request="getAggRequest(State.Month, 'avg', constants.analytics.EV)"
            :period="getPeriod(State.Month)"
          />
          <analytic-card
            :unit="constants.units.Energy"
            :title="ENERGY"
            img="energy.svg"
            :request="getAggRequest(State.Month, 'avg', constants.analytics.EV)"
            :period="getPeriod(State.Month)"
          />
          <analytic-card
            :unit="constants.units.Number"
            :title="NUMBER"
            img="number.svg"
            :request="getAggRequest(State.Month, 'count', constants.analytics.EVChargingCount)"
            :period="getPeriod(State.Month)"
          />
          <analytic-card
            :unit="constants.units.Millisecond"
            :title="DURATION"
            img="time.svg"
            :request="getAggRequest(State.Month, 'avg', constants.analytics.EVChargingDuration)"
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
import NavigationBar from "@/components/layouts/NavigationBar.vue";
import constants from "@/util/constants";
import { ref } from "vue";

const State = Object.freeze({ Day: 0, Week: 1, Month: 2 });
const POWER = "Average Power Consumption";
const ENERGY = "Average Energy Consumption";
const NUMBER = "Number of Charging Events";
const DURATION = "Average Duration of Charging Events";
const TITLE = "EV Charging";
const now = new Date();

export default {
  components: {
    apexchart: VueApexCharts,
    Tabs,
    Tab,
    LineColumnChart,
    AnalyticCard,
    NavigationBar
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
      NUMBER,
      DURATION,
      TITLE,
      now,
      constants,
    };
  },
  methods: {
    getCurrentMonth() {
      return `${now.toLocaleDateString("en", { month: "long" })}`;
    },
    getPeriod(type) {
      let start = new Date(this.getStartTime(now, type));
      return `${
        start.toLocaleDateString("en", constants.timeFormat) +
        ` ~\n` +
        now.toLocaleDateString("en", constants.timeFormat)
      }`;
    },
    getTSRequest(type) {
      let ret = {
        start_time: this.getStartTime(now, type),
        end_time: now.getTime(),
        type: "analytics",
        analytics_name: constants.analytics.EV,
        house_id: localStorage.getItem("house_id"),
      };
      // Weekly and montly data are by default averaged over 1 hour
      if (type == State.Day) {
        ret["average"] = 300000; // 5 min
        ret["fine"] = true;
      }
      return ret;
    },
    getAggRequest(type, aggFunc, formula) {
      let ret = {
        start_time: this.getStartTime(now, type),
        end_time: now.getTime(),
        type: "analytics",
        agg_function: aggFunc,
        analytics_name: formula,
        house_id: localStorage.getItem("house_id"),
      };
      if (type == State.Day) {
        // We want fine-grained data
        ret["fine"] = true;
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
        default:
          // default is today
          start = cur - 86400000; // 1000 * 3600 * 24 = 86400000
      }
      return start;
    },
  },
};
</script>
