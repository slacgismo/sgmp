<template>
  <div
    class="flex items-center bg-white border rounded-sm overflow-hidden shadow"
    v-show="visible"
  >
    <div class="p-4">
      <img :src="getImage()" class="h-12 w-12" />
    </div>
    <div class="text-gray-700">
      <h3 class="text-sm tracking-wider">{{ title }}</h3>
      <p class="text-3xl">{{ value }}</p>
    </div>
  </div>
</template>

<script>
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  name: "DashboardCard",
  props: {
    unit: String, // either power (kW) or time (min)
    title: String,
    img: String,
    request: Object,
  },
  data() {
    return {
      visible: false,
      value: null,
    };
  },
  created() {
    // POST request to fetch data for the dashboard card
    fetch(
        constants.server + "/api/data/read", // endpoint
        httpReq.post(this.request) // requestOptions
      )
      .then(async (response) => {
        const data = await response.json();

        // check for error response
        if (!response.ok || data.value == undefined) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.value = data.value.toFixed(3) + " " + this.unit;
        this.visible = true;
      })
      .catch((error) => {
        this.errorMessage = error;
        console.error(error);
        this.value = "N/A";
        this.visible = true;
      });
  },

  watch: {
    unit: {
      immediate: true,
      handler() {
        document.unit = this.unit;
      },
    },
    title: {
      immediate: true,
      handler() {
        document.title = this.title;
      },
    },
    request: {
      immediate: true,
      handler() {
        document.request = this.request;
      },
    },
  },
  methods: {
    getImage() {
      return "/src/assets/img/" + this.img;
    },
  },
};
</script>