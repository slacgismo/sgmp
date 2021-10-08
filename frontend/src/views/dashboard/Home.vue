<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-xl text-gray-600">{{ "Today's Dashboard : " + getDate() }}</h2>

    <div class="flex items-center space-x-1 text-xs">
      <a href="#" class="font-bold text-indigo-700">Home</a>
      <svg xmlns="http://www.w3.org/2000/svg" class="h-2 w-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
      </svg>
      <span class="text-gray-600">Dashboard</span>
    </div>
  </div>

  <div class="grid grid-cols-1 gap-4 px-4 mt-8 lg:grid-cols-2 xl:grid-cols-4 sm:px-8">
    <router-link :to="{ name: 'solar' }">
      <!-- https://uxwing.com/solar-energy-icon/ -->
      <dashboard-card :isPower="true" title="Solar Power" img="sun.svg"
        :request="getCardRequest(FORMULA.Solar)" />
    </router-link>

    <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <!-- https://www.svgrepo.com/svg/326915/battery-charging-sharp -->
        <img src="../../assets/img/battery.svg" class="h-12 w-12" />
      </div>
      <div class="text-gray-700">
        <h3 class="text-sm tracking-wider">Battery Discharging</h3>
        <p class="text-3xl">27 kW</p>
      </div>
    </div>

    <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <!-- https://www.svgrepo.com/svg/17490/car -->
        <img src="../../assets/img/car.svg" class="h-12 w-12" />
      </div>
      <div class="text-gray-700">
        <h3 class="text-sm tracking-wider">EV Charging</h3>
        <p class="text-3xl">128 min</p>
      </div>
    </div>

    <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <!-- Credit: modified from https://www.svgrepo.com/svg/137351/rounded-plug -->
        <img src="../../assets/img/load.svg" class="h-12 w-12" />
      </div>
      <div class="text-gray-700">
        <h3 class="text-sm tracking-wider">Loads</h3>
        <p class="text-3xl">76 kW</p>
      </div>
    </div>
  </div>

  <div class="grid grid-cols-1 px-4 gap-4 mt-8 lg:grid-cols-2 sm:px-8">
    <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
      <h3 class="text-xl text-gray-600 mb-4">Energy Generation</h3>
      <apexchart type="donut" :height="300" :options="supplyOptions" :series="supplySeries"></apexchart>
    </div>

    <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
      <h3 class="text-xl text-gray-600 mb-4">Power Consumption</h3>
      <apexchart type="line" :height="300" :options="demandOptions" :series="demandSeries"></apexchart>
    </div>
  </div>

  <div class="grid grid-cols-1 px-4 gap-4 mt-8 sm:px-8">
    <three-y-axes-chart title="Grid Frequency and Voltage" leftAxisTitle="Grid frequency (Hz)"
      rightAxis1Title="L1 Voltage (V)" rightAxis2Title="L2 Voltage (V)" request="" />
  </div>
</template>

<script>
import VueApexCharts from 'vue3-apexcharts'
import DashboardCard from '@/components/card/DashboardCard.vue';
import ThreeYAxesChart from '@/components/chart/ThreeYAxesChart.vue';
import supply from '@/data/home/supply.json'
import demand from '@/data/home/demand.json'

// Mapping between energy type and formula
const FORMULA = Object.freeze({ Solar: "sonnen.status.Production_W", Battery: "", EV: "", Load: "" });
const now = new Date();

export default {
  components: {apexchart: VueApexCharts, DashboardCard, ThreeYAxesChart},
  data() {
    return {
      FORMULA,
      now
    }
  },
  setup() {
    let demandLabels = []
    let loadCons = [], evCons = [], battCons = []
    // TODO: ensure Load, EV, Battery follows the same timestamp (at least within 1 hour)
    for (let i = 0; i < demand.EV.length; i++) {
      demandLabels.push(new Date(demand.EV[i].timestamp).getHours())
      loadCons.push(demand.Load[i].data)
      evCons.push(demand.EV[i].data)
      battCons.push(demand.Battery[i].data)
    }

    var demandOptions = {
      chart: {
        height: 350,
        type: 'line',
        stacked: false,
      },
      stroke: {
        width: [0, 2, 5],
        curve: 'smooth'
      },
      plotOptions: {
        bar: {
          columnWidth: '50%'
        }
      },
      
      fill: {
        opacity: [0.85, 0.25, 1],
        gradient: {
          inverseColors: false,
          shade: 'light',
          type: "vertical",
          opacityFrom: 0.85,
          opacityTo: 0.55,
          stops: [0, 100, 100, 100]
        }
      },
      labels: demandLabels,
      markers: {
        size: 0
      },
      xaxis: {
        title: {
          text: 'time',
        },
        type: 'time'
      },
      yaxis: {
        title: {
          text: 'kW',
        },
        min: 0
      },
      legend: {
        position: 'top',
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
      
          }
        }
      }
    }

    const demandSeries = [{
      name: 'Load',
      type: 'column',
      data: loadCons
    }, {
      name: 'EV',
      type: 'area',
      data: evCons
    }, {
      name: 'Battery',
      type: 'line',
      data: battCons
    }]

    let supplySeries = [], supplyLabels = []
    for (let i = 0; i < supply.length; i++) {
      supplyLabels.push(supply[i].type);
      supplySeries.push(supply[i].energy);
    }

    const supplyOptions = {
      chart: {
        id: 'consumption-chart',
      },
      labels: supplyLabels,
      legend: {
        position: 'right',
      },
      tooltip: {
        shared: true,
        intersect: false,
        y: {
          formatter: function (y) {
            if (typeof y !== "undefined") {
              return y + " kWh";
            }
            return y;
      
          }
        }
      }
    }

    return {
      demandOptions,
      demandSeries,
      supplyOptions,
      supplySeries
    }
  },
  methods: {
    getDate() {
      const format = {
        year: "numeric",
        month: "short",
        day: "numeric"
      };
      return `${new Date().toLocaleDateString("en", format)}`;
    },
    // TODO: update when the backend API is ready to fetch current data
    getCardRequest(formula) {
      return JSON.stringify({
        "start_time": now.getTime()-3600,
        "end_time": now.getTime(),
        "type": "analytics",
        "agg_function": "max",
        "formula": formula
      });
    }
  }
}
</script>
