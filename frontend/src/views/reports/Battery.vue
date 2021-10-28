<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <div class="flex items-center">
      <!-- https://www.svgrepo.com/svg/326915/battery-charging-sharp -->
      <img src="/src/assets/img/battery.svg" class="h-12 w-12" />
      <h2 class="px-4 text-xl text-gray-400">
        Reports / <span class="text-xl text-gray-600">Battery</span>
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
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-8">
          <!-- https://www.svgrepo.com/svg/89155/battery -->
          <analytic-card
            :unit="constants.units.Power"
            :title="CHARGING"
            img="charging.svg"
            :period="getPeriod(State.Day)"
            :request="
              getAggRequest(State.Day, 'avg', constants.formula.BatteryCharging)
            "
          />
          <analytic-card
            :unit="constants.units.Power"
            :title="DISCHARGING"
            img="discharging.svg"
            :period="getPeriod(State.Day)"
            :request="
              getAggRequest(State.Day, 'avg', constants.formula.BatteryDischarging)
            "
          />
        </div>
        <left-right-y-axes-chart
          :title="TITLE"
          leftAxisTitle="SOC (%)" :leftAxisType="constants.chartTypes.Column"
          :rightAxis1Title="CHARGINGAXIS"
          :rightAxis2Title="DISCHARGINGAXIS"
          :request="getTSRequest(State.Day)"
        />
      </tab>

      <tab title="Last 7 days">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-8">
          <analytic-card
            :unit="constants.units.Power"
            :title="CHARGING"
            img="charging.svg"
            :period="getPeriod(State.Week)"
            :request="
              getAggRequest(State.Week, 'avg', constants.formula.BatteryCharging)
            "
          />
          <analytic-card
            :unit="constants.units.Power"
            :title="DISCHARGING"
            img="discharging.svg"
            :period="getPeriod(State.Week)"
            :request="
              getAggRequest(State.Week, 'avg', constants.formula.BatteryDischarging)
            "
          />
        </div>
        <left-right-y-axes-chart
          :title="TITLE"
          leftAxisTitle="SOC (%)" :leftAxisType="constants.chartTypes.Column"
          :rightAxis1Title="CHARGINGAXIS"
          :rightAxis2Title="DISCHARGINGAXIS"
          :request="getTSRequest(State.Week)"
        />
      </tab>

      <tab :title="getCurrentMonth()">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-4 mb-8">
          <analytic-card
            :unit="constants.units.Power"
            :title="CHARGING"
            img="charging.svg"
            :period="getPeriod(State.Month)"
            :request="
              getAggRequest(State.Month, 'avg', constants.formula.BatteryCharging)
            "
          />
          <analytic-card
            :unit="constants.units.Power"
            :title="DISCHARGING"
            img="discharging.svg"
            :period="getPeriod(State.Month)"
            :request="
              getAggRequest(State.Month, 'avg', constants.formula.BatteryDischarging)
            "
          />
          <!-- <analytic-card
            :unit="constants.units.Percentage"
            :title="HIGH"
            img="champion.svg"
            :request="
              getAggRequest(
                State.Month,
                'max',
                constants.formula.SOC
              )
            "
          />
          <analytic-card
            :unit="constants.units.Percentage"
            :title="LOW"
            img="down-arrow.svg"
            :request="
              getAggRequest(
                State.Month,
                'min',
                constants.formula.SOC
              )
            "
          /> -->
        </div>
        <left-right-y-axes-chart
          :title="TITLE"
          leftAxisTitle="SOC (%)" :leftAxisType="constants.chartTypes.Column"
          :rightAxis1Title="CHARGINGAXIS"
          :rightAxis2Title="DISCHARGINGAXIS"
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
import LeftRightYAxesChart from "@/components/chart/LeftRightYAxesChart.vue";
import AnalyticCard from "@/components/card/AnalyticCard.vue";
import constants from '@/util/constants';
import { ref } from "vue";
const State = Object.freeze({ Day: 0, Week: 1, Month: 2 });
const CHARGING = "Average Charging";
const DISCHARGING = "Average Discharging";
const CHARGINGAXIS = "Average Charging (kW)";
const DISCHARGINGAXIS = "Average Discharging (kW)";
const HIGH = "Highest State Of Charge (SOC)";
const LOW = "Lowest State Of Charge (SOC)";
const TITLE = "Battery Power, Energy and State Of Charge (SOC)";
const now = new Date();

export default {
  components: {
    apexchart: VueApexCharts,
    Tabs,
    Tab,
    LeftRightYAxesChart,
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
      CHARGING,
      DISCHARGING,
      CHARGINGAXIS,
      DISCHARGINGAXIS,
      HIGH,
      LOW,
      TITLE,
      now,
      constants
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
      let interval = 3600000; // 1 hour = 60 * 60 * 1000
      if (type == State.Day) {
        interval = 300000; // 5 min
      }
      return {
        "start_time": this.getStartTime(now, type),
        "end_time": now.getTime(),
        "type": "analytics",
        "formula": [constants.formula.SOC, constants.formula.BatteryCharging, constants.formula.BatteryDischarging],
        "average": interval,
        "house_id": localStorage.getItem("house_id")
      };
    },
    getAggRequest(type, aggFunc, formula) {
      return {
        start_time: this.getStartTime(now, type),
        end_time: now.getTime(),
        type: "analytics",
        agg_function: aggFunc,
        formula: formula,
        house_id: localStorage.getItem("house_id")
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
