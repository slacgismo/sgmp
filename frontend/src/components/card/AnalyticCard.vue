<template>
  <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow" v-show="visible">
    <div class="p-2">
      <!-- https://www.svgrepo.com/svg/203990/trophy-champion -->
      <img :src="getImage()" class="h-24 w-24" />
    </div>
    
    <div class="text-gray-700 px-4">
      <h3 class="text-sm tracking-wider">{{ title }}</h3>
      <div class="flex items-center gap-4">
        <p class="text-3xl sm:text-2xl">{{ value }}</p>
        <!-- https://www.svgrepo.com/svg/305138/arrowhead-left -->
        <img src="/src/assets/img/arrow.svg" class="h-12 w-12" />
        <!-- <span class="text-8xl font-thin text-gray-300 italic">/</span> -->
        <p class="text-xl sm:text-base text-right tracking-wider pr-4 whitespace-pre-line">{{ time }}</p>
      </div>
    </div>
  </div>
</template>

<script>
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  name: "AnalyticCard",
  props: {
    unit: String,
    title: String,
    img: String,
    period: String,
    request: String
  },
  data() {
    return {
      visible: false,
      value: null,
      time: null
    };
  },
  created() {
    // POST request to fetch data for the analytics card
    fetch(
        constants.server + "/api/data/read", // endpoint
        httpReq.post(this.request) // requestOptions
      )
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        if (data.value == undefined) {
          this.value = "N/A";
        } else {
          switch (this.unit) {
            case constants.units.Power:
            case constants.units.Seconds:
              this.value = (data.value).toFixed(3) + " " + this.unit;
              break;
            case constants.units.Energy:
              this.value = (data.value / 12).toFixed(3) + " " + this.unit;
              break;
            case constants.units.Percentage:
              this.value = data.value + " " + this.unit;
              break;
            default:
              this.value = data.value.toFixed(3);
          }
        }
        
        if (!this.time) {
          this.time = new Date(data.timestamp)
          .toLocaleDateString("en", constants.timeFormat);
        }
        this.visible = true;
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
  },

  watch: {
    unit: {
      immediate: true,
      handler() {
        document.unit = this.unit;
      }
    },
    title: {
      immediate: true,
      handler() {
        document.title = this.title;
      }
    },
    period: {
      immediate: true,
      handler() {
        this.time = this.period;
      }
    },
    request: {
      immediate: true,
      handler() {
        document.request = this.request;
      }
    }
  },
  methods: {
    getImage () {
      return "/src/assets/img/" + this.img;
    }
  }
};
</script>