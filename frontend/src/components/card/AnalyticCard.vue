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

export default {
  name: "AnalyticCard",
  props: {
    isPower: Boolean, // either power (W) or energy (kWh)
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
    // POST request to fetch data for the line-column chart
    const requestOptions = {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: this.request
    };
    fetch('http://ec2-18-144-174-142.us-west-1.compute.amazonaws.com:5000/api/data/read', requestOptions)
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        if (this.isPower) {
          this.value = (data.value / 1000).toFixed(2) + " kW";
        } else {
          // TODO: update formula sonnen.status.Production_W?
          this.value = (data.value / 12000).toFixed(2) + " kWh";
        }
        
        if (!this.time) {
          this.time = new Date(data.timestamp)
          .toLocaleDateString("en", {month: "short", day:"numeric", hour: "numeric", minute:"numeric"});
          // .toLocaleTimeString("en", {day:"numeric", hour: "numeric", minute:"numeric"});
        }
        this.visible = true;
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
  },

  watch: {
    isPower: {
      immediate: true,
      handler() {
        document.isPower = this.isPower;
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