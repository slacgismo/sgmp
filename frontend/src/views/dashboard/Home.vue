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

    <router-link :to="{ name: 'battery' }">
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
    <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
      <h3 class="text-xl text-gray-600 mb-4">Energy Generation</h3>
      <apexchart
        :type="constants.chartTypes.Donut"
        :height="300"
        :options="supplyOptions"
        :series="supplySeries"
      ></apexchart>
    </div>

    <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
      <h3 class="text-xl text-gray-600 mb-4">Power Consumption</h3>
      <apexchart
        :type="constants.chartTypes.Line"
        :height="300"
        :options="demandOptions"
        :series="demandSeries"
      ></apexchart>
    </div>
  </div>

  <div class="grid grid-cols-1 px-4 gap-4 mt-8 sm:px-8">
    <three-y-axes-chart
      title="Grid Frequency and Voltage"
      leftAxisTitle="Grid frequency (Hz)"
      :leftAxisType="constants.chartTypes.Line"
      rightAxis1Title="L1 Voltage (V)"
      rightAxis2Title="L2 Voltage (V)"
      :request="getTSRequest()"
    />
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";
import DashboardCard from "@/components/card/DashboardCard.vue";
import ThreeYAxesChart from "@/components/chart/ThreeYAxesChart.vue";
import supply from "@/data/home/supply.json";
import demand from "@/data/home/demand.json";
import constants from "@/util/constants";
const now = new Date();

export default {
  components: { apexchart: VueApexCharts, DashboardCard, ThreeYAxesChart },
  data() {
    return {
      now,
      constants,
    };
  },
  setup() {
    let demandLabels = [];
    let loadCons = [],
      evCons = [],
      battCons = [];
    // TODO: ensure Load, EV, Battery follows the same timestamp (at least within 1 hour)
    for (let i = 0; i < demand.EV.length; i++) {
      demandLabels.push(new Date(demand.EV[i].timestamp).getHours());
      loadCons.push(demand.Load[i].data);
      evCons.push(demand.EV[i].data);
      battCons.push(demand.Battery[i].data);
    }

    var demandOptions = {
      chart: {
        height: 350,
        type: "line",
        stacked: false,
      },
      stroke: {
        width: [0, 2, 5],
        curve: "smooth",
      },
      plotOptions: {
        bar: {
          columnWidth: "50%",
        },
      },

      fill: {
        opacity: [0.85, 0.25, 1],
        gradient: {
          inverseColors: false,
          shade: "light",
          type: "vertical",
          opacityFrom: 0.85,
          opacityTo: 0.55,
          stops: [0, 100, 100, 100],
        },
      },
      labels: demandLabels,
      markers: {
        size: 0,
      },
      xaxis: {
        title: {
          text: "time",
        },
        type: "time",
      },
      yaxis: {
        title: {
          text: "kW",
        },
        min: 0,
      },
      legend: {
        position: "top",
      },
      tooltip: {
        shared: true,
        intersect: false,
        y: {
          formatter: function (y) {
            if (typeof y !== "undefined") {
              return y.toFixed(0) + " kW";
            }
            return y;
          },
        },
      },
    };

    const demandSeries = [
      {
        name: "Load",
        type: "column",
        data: loadCons,
      },
      {
        name: "EV",
        type: "area",
        data: evCons,
      },
      {
        name: "Battery",
        type: "line",
        data: battCons,
      },
    ];

    let supplySeries = [],
      supplyLabels = [];
    for (let i = 0; i < supply.length; i++) {
      supplyLabels.push(supply[i].type);
      supplySeries.push(supply[i].energy);
    }

    const supplyOptions = {
      chart: {
        id: "consumption-chart",
      },
      labels: supplyLabels,
      legend: {
        position: "right",
      },
      tooltip: {
        shared: true,
        intersect: false,
        y: {
          formatter: function (y) {
            if (typeof y !== "undefined") {
              return y + " " + constants.units.Energy;
            }
            return y;
          },
        },
      },
    };

    return {
      demandOptions,
      demandSeries,
      supplyOptions,
      supplySeries,
    };
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
        start_time: now.getTime() - 20000,  // 20 s
        end_time: now.getTime(),
        type: "analytics",
        agg_function: "max",
        formula: formula,
      };
    },
    getTSRequest() {
      return {
        // last 24 hours: 24 * 60 * 60 * 1000
        start_time: now.getTime() - 86400000,
        end_time: now.getTime(),
        type: "analytics",
        formula: [
          "egauge.A.L1_Frequency",
          "egauge.A.L1_Voltage",
          "egauge.A.L2_Voltage",
        ],
        average: 300000, // 5 minute = 5 * 60 * 1000
      };
    },
  },
};
</script>