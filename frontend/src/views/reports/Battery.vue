<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <div class="flex items-center">
      <!-- https://www.svgrepo.com/svg/326915/battery-charging-sharp -->
      <img src="/src/assets/img/battery.svg" class="h-12 w-12" />
      <h2 class="px-4 text-xl text-gray-400">
        Reports / <span class="text-xl text-gray-600">Battery</span>
      </h2>
    </div>
    <navigation-bar plainText="Reports" />
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
              getAggRequest(State.Day, 'avg', constants.analytics.BatteryCharging)
            "
          />
          <analytic-card
            :unit="constants.units.Power"
            :title="DISCHARGING"
            img="discharging.svg"
            :period="getPeriod(State.Day)"
            :request="
              getAggRequest(State.Day, 'avg', constants.analytics.BatteryDischarging)
            "
          />
        </div>
        <left-right-y-axes-chart
          :title="TITLE"
          :axes="axes"
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
              getAggRequest(State.Week, 'avg', constants.analytics.BatteryCharging)
            "
          />
          <analytic-card
            :unit="constants.units.Power"
            :title="DISCHARGING"
            img="discharging.svg"
            :period="getPeriod(State.Week)"
            :request="
              getAggRequest(State.Week, 'avg', constants.analytics.BatteryDischarging)
            "
          />
        </div>

        <left-right-y-axes-chart
          :title="TITLE"
          :axes="axes"
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
              getAggRequest(State.Month, 'avg', constants.analytics.BatteryCharging)
            "
          />
          <analytic-card
            :unit="constants.units.Power"
            :title="DISCHARGING"
            img="discharging.svg"
            :period="getPeriod(State.Month)"
            :request="
              getAggRequest(State.Month, 'avg', constants.analytics.BatteryDischarging)
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
                constants.analytics.SOC
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
                constants.analytics.SOC
              )
            "
          /> -->
        </div>

        <left-right-y-axes-chart
          :title="TITLE"
          :axes="axes"
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
import NavigationBar from "@/components/layouts/NavigationBar.vue";
import httpReq from "@/util/requestOptions";
import constants from '@/util/constants';
import { ref } from "vue";

const State = Object.freeze({ Day: 0, Week: 1, Month: 2 });
const CHARGING = "Average Charging";
const DISCHARGING = "Average Discharging";
// const HIGH = "Highest State Of Charge (SOC)";
// const LOW = "Lowest State Of Charge (SOC)";
const TITLE = "Battery Power";
const now = new Date();
const ts_analytics = [constants.analytics.SOC, constants.analytics.BatteryCharging, constants.analytics.BatteryDischarging];

export default {
  components: {
    apexchart: VueApexCharts,
    Tabs,
    Tab,
    LeftRightYAxesChart,
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
      CHARGING,
      DISCHARGING,
      // HIGH,
      // LOW,
      TITLE,
      now,
      constants,
      analyticItems: null,
      axes: [
        {title: "State of Charge (%)", type: constants.chartTypes.Column},
        {title: "Average Charging (kW)", type: constants.chartTypes.Line}, 
        {title: "Average Discharging (kW)", type: constants.chartTypes.Line}
      ]
    };
  },
  beforeCreate() {
    // Fetch data for the analytic items list
      fetch(
          constants.server + "/api/analytics/list", // endpoint
          httpReq.post({ house_id: localStorage.getItem("house_id") }) // requestOptions
        )
      .then(response => response.json())
      .then(data => {
        this.analyticItems = [];
        for (let i = 0; i < ts_analytics.length; i++) {
          if (data.analytics.some(item => item.name === ts_analytics[i])) {
            this.analyticItems.push(ts_analytics[i]);
          } else {
            this.axes.splice(i, 1);
          }
        }
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
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
      if (!this.analyticItems) {
        return;
      }
      let ret = {
        "start_time": this.getStartTime(now, type),
        "end_time": now.getTime(),
        "type": "analytics",
        "analytics_name": this.analyticItems,
        "house_id": localStorage.getItem("house_id")
      };
      // Weekly and montly data are by default averaged over 1 hour
      if (type == State.Day) {
        ret['average'] = 300000; // 5 min
        ret['fine'] = true;
      }
      return ret;
    },
    getAggRequest(type, aggFunc, analyticsName) {
      let ret = {
        start_time: this.getStartTime(now, type),
        end_time: now.getTime(),
        type: "analytics",
        agg_function: aggFunc,
        analytics_name: analyticsName,
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
        default:
          // default is today
          start = cur - 86400000; // 1000 * 3600 * 24 = 86400000
      }
      return start;
    }
  },
};
</script>
