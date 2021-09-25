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
    <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-12 w-12 text-white"
          fill="none"
          viewBox="0 0 20 20"
          stroke="orange"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M5.114,5.726c0.169,0.168,0.442,0.168,0.611,0c0.168-0.169,0.168-0.442,0-0.61L3.893,3.282c-0.168-0.168-0.442-0.168-0.61,0c-0.169,0.169-0.169,0.442,0,0.611L5.114,5.726z M3.955,10c0-0.239-0.193-0.432-0.432-0.432H0.932C0.693,9.568,0.5,9.761,0.5,10s0.193,0.432,0.432,0.432h2.591C3.761,10.432,3.955,10.239,3.955,10 M10,3.955c0.238,0,0.432-0.193,0.432-0.432v-2.59C10.432,0.693,10.238,0.5,10,0.5S9.568,0.693,9.568,0.932v2.59C9.568,3.762,9.762,3.955,10,3.955 M14.886,5.726l1.832-1.833c0.169-0.168,0.169-0.442,0-0.611c-0.169-0.168-0.442-0.168-0.61,0l-1.833,1.833c-0.169,0.168-0.169,0.441,0,0.61C14.443,5.894,14.717,5.894,14.886,5.726 M5.114,14.274l-1.832,1.833c-0.169,0.168-0.169,0.441,0,0.61c0.168,0.169,0.442,0.169,0.61,0l1.833-1.832c0.168-0.169,0.168-0.442,0-0.611C5.557,14.106,5.283,14.106,5.114,14.274 M19.068,9.568h-2.591c-0.238,0-0.433,0.193-0.433,0.432s0.194,0.432,0.433,0.432h2.591c0.238,0,0.432-0.193,0.432-0.432S19.307,9.568,19.068,9.568 M14.886,14.274c-0.169-0.168-0.442-0.168-0.611,0c-0.169,0.169-0.169,0.442,0,0.611l1.833,1.832c0.168,0.169,0.441,0.169,0.61,0s0.169-0.442,0-0.61L14.886,14.274z M10,4.818c-2.861,0-5.182,2.32-5.182,5.182c0,2.862,2.321,5.182,5.182,5.182s5.182-2.319,5.182-5.182C15.182,7.139,12.861,4.818,10,4.818M10,14.318c-2.385,0-4.318-1.934-4.318-4.318c0-2.385,1.933-4.318,4.318-4.318c2.386,0,4.318,1.933,4.318,4.318C14.318,12.385,12.386,14.318,10,14.318 M10,16.045c-0.238,0-0.432,0.193-0.432,0.433v2.591c0,0.238,0.194,0.432,0.432,0.432s0.432-0.193,0.432-0.432v-2.591C10.432,16.238,10.238,16.045,10,16.045"
          />
        </svg>
      </div>
      <div class="text-gray-700">
        <h3 class="text-sm tracking-wider">Solar Power</h3>
        <p class="text-3xl">128 Walt</p>
      </div>
    </div>

    <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-12 w-12 text-white"
          fill="none"
          viewBox="0 0 20 20"
          stroke="green"
        >
          <path fill="none" d="M18.796,6.974h-0.652V5.201c0-0.457-0.372-0.831-0.831-0.831H1.204c-0.459,0-0.831,0.373-0.831,0.831v9.599c0,0.459,0.372,0.831,0.831,0.831h16.11c0.459,0,0.831-0.372,0.831-0.831v-1.704h0.652c0.459,0,0.831-0.37,0.831-0.831v-4.46C19.627,7.346,19.256,6.974,18.796,6.974z M16.483,13.969H2.034V6.031h14.448v1.773v4.46V13.969z" />
					<polygon fill="none" points="8.677,7.451 8.653,7.453 4.338,11.415 8.336,9.719 9.84,12.551 14.179,8.585 10.179,10.282 	"></polygon>
        </svg>
      </div>
      <div class="text-gray-700">
        <h3 class="text-sm tracking-wider">Battery Discharging</h3>
        <p class="text-3xl">27 kW</p>
      </div>
    </div>

    <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-12 w-12 text-white"
          fill="none"
          viewBox="0 0 24 24"
          stroke="indigo"
        >
        <!-- https://iconmonstr.com/license/ -->
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M23.5 7c.276 0 .5.224.5.5v.511c0 .793-.926.989-1.616.989l-1.086-2h2.202zm-1.441 3.506c.639 1.186.946 2.252.946 3.666 0 1.37-.397 2.533-1.005 3.981v1.847c0 .552-.448 1-1 1h-1.5c-.552 0-1-.448-1-1v-1h-13v1c0 .552-.448 1-1 1h-1.5c-.552 0-1-.448-1-1v-1.847c-.608-1.448-1.005-2.611-1.005-3.981 0-1.414.307-2.48.946-3.666.829-1.537 1.851-3.453 2.93-5.252.828-1.382 1.262-1.707 2.278-1.889 1.532-.275 2.918-.365 4.851-.365s3.319.09 4.851.365c1.016.182 1.45.507 2.278 1.889 1.079 1.799 2.101 3.715 2.93 5.252zm-16.059 2.994c0-.828-.672-1.5-1.5-1.5s-1.5.672-1.5 1.5.672 1.5 1.5 1.5 1.5-.672 1.5-1.5zm10 1c0-.276-.224-.5-.5-.5h-7c-.276 0-.5.224-.5.5s.224.5.5.5h7c.276 0 .5-.224.5-.5zm2.941-5.527s-.74-1.826-1.631-3.142c-.202-.298-.515-.502-.869-.566-1.511-.272-2.835-.359-4.441-.359s-2.93.087-4.441.359c-.354.063-.667.267-.869.566-.891 1.315-1.631 3.142-1.631 3.142 1.64.313 4.309.497 6.941.497s5.301-.184 6.941-.497zm2.059 4.527c0-.828-.672-1.5-1.5-1.5s-1.5.672-1.5 1.5.672 1.5 1.5 1.5 1.5-.672 1.5-1.5zm-18.298-6.5h-2.202c-.276 0-.5.224-.5.5v.511c0 .793.926.989 1.616.989l1.086-2z"/>
          />
        </svg>
      </div>
      <div class="text-gray-700">
        <h3 class="text-sm tracking-wider">EV Charging</h3>
        <p class="text-3xl">128 min</p>
      </div>
    </div>

    <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
      <div class="p-4">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-12 w-12 text-white"
          fill="none"
          viewBox="0 0 24 24"
          stroke="red"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M4 7v10c0 2.21 3.582 4 8 4s8-1.79 8-4V7M4 7c0 2.21 3.582 4 8 4s8-1.79 8-4M4 7c0-2.21 3.582-4 8-4s8 1.79 8 4m0 5c0 2.21-3.582 4-8 4s-8-1.79-8-4"
          />
        </svg>
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
    <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
      <h3 class="text-xl text-gray-600 mb-4">Grid Frequency</h3>
      <apexchart type="line" :height="300" :options="timeSeries" :series="freqSeries"></apexchart>
    </div>
  </div>
</template>

<script>
import VueApexCharts from 'vue3-apexcharts'
import supply from '@/data/home/supply.json'
import demand from '@/data/home/demand.json'
import frequency from '@/data/home/frequency.json'

export default {
  components: {
    apexchart: VueApexCharts
  },

  setup() {
    let demandLabels = []
    let loadCons = [], evCons = [], battCons = []
    // TODO: ensure Load, EV, Battery follows the same timestamp (at least within 1 hour)
    for (let i = 0; i < demand.EV.length; i++) {
      demandLabels.push(new Date(demand.EV[i].timestamp).getHours())
      loadCons.push(demand.Load[i].power)
      evCons.push(demand.EV[i].power)
      battCons.push(demand.Battery[i].power)
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

    let timeLabels = [], freq = []
    for (let i = 0; i < frequency.length; i++) {
      timeLabels.push(new Date(frequency[i].timestamp).getHours())
      freq.push(frequency[i].frequency)
    }

    const timeSeries = {
      chart: {
        id: 'grid-freq',
      },
      labels: timeLabels,
      legend: {
        position: 'bottom',
      },
      yaxis: {
        title: {
          text: 'Hz',
        },
        min: 0
      },
      tooltip: {
        shared: true,
        intersect: false,
        y: {
          formatter: function (y) {
            if (typeof y !== "undefined") {
              return y + " Hz";
            }
            return y;
      
          }
        }
      }
    }

    const freqSeries = [{
      name: 'Grid frequency',
      type: 'line',
      data: freq
    }]

    return {
      demandOptions,
      demandSeries,
      supplyOptions,
      supplySeries,
      timeSeries,
      freqSeries
    }
  },
  methods: {
    getDate() {
      const options = {
        year: "numeric",
        month: "short",
        day: "numeric"
      };

      return `${new Date().toLocaleDateString("en", options)}`;
    }
  }
}
</script>
