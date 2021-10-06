<template>
  <div class="px-4 py-2 bg-white border rounded-md overflow-hidden shadow">
    <h3 class="text-xl text-gray-600 mb-4">{{ title }}</h3>
    <apexchart
      type="line"
      :height="300"
      :options="options"
      :series="series"
    ></apexchart>
  </div>
</template>

<script>
import VueApexCharts from "vue3-apexcharts";

export default {
  name: "LineColumnChart",
  components: { apexchart: VueApexCharts },
  props: {
    title: String,
  },
  setup() {
    var options = {
      chart: {
        height: 350,
        type: "line",
      },
      stroke: {
        width: [0, 4],
      },
      dataLabels: {
        enabled: true,
        enabledOnSeries: [1],
      },
      labels: [
        "13:00",
        "13:05",
        "13:10",
        "13:15",
        "13:20",
        "13:25",
        "13:30",
        "13:35",
        "13:40",
        "13:45",
        "13:50",
        "13:55",
        "14:00",
      ],
      xaxis: {
        type: "time",
      },
      yaxis: [
        {
          title: {
            text: "Average Power (kW)",
          },
        },
        {
          opposite: true,
          title: {
            text: "Average Energy (kWh)",
          },
        },
      ],
    };

    var series = [
      {
        name: "Average Power (kW)",
        type: "column",
        data: [390, 440, 505, 414, 671, 227, 413, 201, 352, 752, 320, 257, 160],
      },
      {
        name: "Average Energy (kWh)",
        type: "line",
        data: [18, 23, 42, 35, 27, 43, 22, 17, 31, 22, 22, 12, 16],
      },
    ];

    // let supplySeries = [],
    //   supplyLabels = [];
    // supplyLabels.push("Solar");
    // supplySeries.push(78);

    // const supplyOptions = {
    //   chart: {
    //     id: "solar-chart",
    //   },
    //   // plotOptions: {
    //   //   radialBar: {
    //   //     startAngle: -90,
    //   //     endAngle: 90,
    //   //     track: {
    //   //       // background: '#333',
    //   //       startAngle: -90,
    //   //       endAngle: 90,
    //   //     },
    //   //     dataLabels: {
    //   //       name: {
    //   //         show: false,
    //   //       },
    //   //       // value: {
    //   //       //   fontSize: "30px",
    //   //       //   show: true
    //   //       // }
    //   //     }
    //   //   }
    //   // },
    //   labels: supplyLabels,
    //   legend: {
    //     position: "right",
    //   },
    //   tooltip: {
    //     shared: true,
    //     intersect: false,
    //     y: {
    //       formatter: function (y) {
    //         if (typeof y !== "undefined") {
    //           return y + " kWh";
    //         }
    //         return y;
    //       },
    //     },
    //   },
    // };

    return {
      options,
      series
    };
  },
  watch: {
    title: {
      immediate: true,
      handler() {
        document.title = this.title;
      }
    }
  }
};
</script>