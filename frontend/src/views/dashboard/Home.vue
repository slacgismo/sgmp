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
      <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
        <div class="p-4">
          <!-- https://uxwing.com/solar-energy-icon/ -->
          <img src="../../assets/img/sun.svg" class="h-12 w-12" />
        </div>
        <div class="text-gray-700">
          <h3 class="text-sm tracking-wider">Solar Power</h3>
          <p class="text-3xl">128 Walt</p>
        </div>
      </div>
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
    <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
      <h3 class="text-xl text-gray-600 mb-4">Grid Frequency and Voltage</h3>
      <apexchart type="line" :height="300" :options="timeSeries" :series="freqSeries"></apexchart>
    </div>
  </div>
</template>

<script>
import VueApexCharts from 'vue3-apexcharts'
import supply from '@/data/home/supply.json'
import demand from '@/data/home/demand.json'
import frequency from '@/data/home/frequency.json'
import voltage from '@/data/home/voltage.json'

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

    const colorBlue = '#008FFB';
    const colorOrange = '#00E396';
    const colorGreen = '#FEB019';

    const format = {
      month: "short",
      day: "numeric",
      hour: '2-digit',
      minute:'2-digit'
    };
    let timeLabels = [], freq = [], volt = []
    for (let i = 0; i < frequency.length; i++) {
      timeLabels.push(new Date(frequency[i].timestamp).toLocaleTimeString("en", format))
      freq.push(frequency[i].data)
      volt.push(voltage[i].data)
    }

    const timeSeries = {
      chart: {
        id: 'grid-freq',
      },
      labels: timeLabels,
      legend: {
        position: 'bottom',
      },
      yaxis: [
        {
          axisTicks: {
            show: true,
          },
          axisBorder: {
            show: true,
            color: colorBlue
          },
          labels: {
            style: {
              colors: colorBlue
            }
          },
          title: {
            text: "Grid frequency (Hz)",
            style: {
              color: colorBlue
            }
          },
          tooltip: {
            enabled: true
          }
        },
        {
          seriesName: 'Voltage1',
          opposite: true,
          axisTicks: {
            show: true,
          },
          axisBorder: {
            show: true,
            color: colorOrange
          },
          labels: {
            style: {
              colors: colorOrange
            }
          },
          title: {
            text: "L1 Voltage (V)",
            style: {
              color: colorOrange
            }
          },
        },
        {
          seriesName: 'Voltage2',
          opposite: true,
          axisTicks: {
            show: true,
          },
          axisBorder: {
            show: true,
            color: colorGreen
          },
          labels: {
            style: {
              colors: colorGreen
            },
          },
          title: {
            text: "L2 Voltage (V)",
            style: {
              color: colorGreen
            }
          }
        }
        
      ],
      tooltip: {
        shared: true,
        intersect: false,
        y: [
          {
            formatter: function (y) {
              if (typeof y !== "undefined") {
                return y + " Hz";
              }
              return y;
        
            }
          },
          {
            formatter: function (y) {
              if (typeof y !== "undefined") {
                return y + " V";
              }
              return y;
        
            }
          },
          {
            formatter: function (y) {
              if (typeof y !== "undefined") {
                return y + " V";
              }
              return y;
        
            }
          }
        ]
      }
    }

    const freqSeries = [{
      name: 'Grid frequency',
      type: 'column',
      data: freq
    }, {
      name: 'L1 Voltage',
      type: 'line',
      data: volt
    }, {
      name: 'L2 Voltage',
      type: 'line',
      data: volt
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
