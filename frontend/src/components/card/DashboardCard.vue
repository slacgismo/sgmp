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
    isPower: Boolean, // either power (kW) or time (min)
    title: String,
    img: String,
    request: String,
  },
  data() {
    return {
      visible: false,
      value: null,
    };
  },
  created() {
    // POST request to fetch data for the line-column chart
    fetch(
        constants.server + "/api/data/read", // endpoint
        httpReq.post(this.request) // requestOptions
      )
      .then(async (response) => {
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
          // TODO: time?
        }

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
    isPower: {
      immediate: true,
      handler() {
        document.isPower = this.isPower;
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