<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Update Device</h2>

    <div class="flex items-center space-x-1 text-xs">
      <router-link to="/" class="font-bold text-indigo-700">Home</router-link>
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
      <router-link to="/devices" class="font-bold text-indigo-700">Devices</router-link>
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
      <span class="text-gray-600">Update</span>
    </div>
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent>
        <div class="flex items-center">
          <label for="device-name" class="w-1/6 text-gray-600 font-bold">Device Name</label>
          <div class="relative w-5/6 font-mono">
            {{ name }}
          </div>
        </div>

        <div class="flex items-center">
          <label for="device-type" class="w-1/6 text-gray-600 font-bold">Type</label>
          <div class="relative w-5/6 font-mono">
            {{ type }}
          </div>
        </div>

        <div class="flex items-center">
          <label for="device-description" class="w-1/6 text-gray-600 font-bold">Description</label>
          <div class="relative w-5/6">
            <input
              id="device-description"
              name="device-description"
              type="text"
              v-model="description"
              class="
                w-full
                py-4
                text-sm text-gray-900
                rounded-md
                border border-gray-300
                focus:outline-none
                focus:ring-blue-500
                focus:border-blue-500
                focus:z-10
              "
              placeholder="Description"
              required=""
            />
          </div>
        </div>

        <div class="flex items-center">
          <label for="device-config" class="w-1/6 text-gray-600 font-bold">Config</label>
          <div class="relative text-gray-400 w-5/6">
            <textarea
              id="device-config"
              name="device-config"
              type="text"
              v-model="configStr"
              class="
                w-full
                py-4
                h-72
                text-sm text-gray-900
                rounded-md
                border border-gray-300
                focus:outline-none
                focus:ring-blue-500
                focus:border-blue-500
                focus:z-10
                font-mono
              "
              placeholder="Device config JSON"
              required=""
            ></textarea>
          </div>
        </div>

        <div class="flex justify-evenly content-center p-8">
          <button
            class="
              py-4
              w-36
              text-sm text-white
              rounded-md
              bg-gray-400
              hover:bg-gray-300
            "
            @click="cancel()"
          >
            Cancel
          </button>
          <button
            class="
              py-4
              w-36
              text-sm text-white
              rounded-md
              bg-red-900
              hover:bg-red-800
              focus:outline-none
              focus:ring-2
              focus:ring-offset-2
              focus:ring-red-700
            "
            @click="saveChange()"
          >
            Update
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: {
  },
  mounted() {
    // Fetch data for the device details
    fetch(
        constants.server + "/api/device/details", // endpoint
        httpReq.post({ device_id: this.$route.params.id }) // requestOptions
      )
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.name = data.device.name;
        this.type = data.device.type;
        this.description = data.device.description;
        this.configStr = JSON.stringify(data.device.config, null, 2);
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
  },
  data() {
    return {
      name: '',
      type: '',
      description: '',
      configStr: ''
    };
  },
  methods: {
    validateCreate() {
      if (this.description) {
        try {
          JSON.parse(this.configStr);
        } catch (e) {
          alert('Please enter valid JSON config!');
          return false;
        }
        return true;
      }
      return false;
    },
    saveChange() {
      if (!this.validateCreate()) {
        return;
      }
      // POST request to update device
      fetch(
        constants.server + "/api/device/update", // endpoint
        httpReq.post({ device_id: this.$route.params.id, description: this.description, config: JSON.parse(this.configStr) })
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.$router.push("/devices");
        })
        .catch((error) => {
          this.errorMessage = error;
          alert("Device update error: " + error);
        });
    },
    cancel() {
      this.$router.back();
      return true;
    },
  },
};
</script>