<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Create Device</h2>
    <navigation-bar naviText="Devices" routePath="/devices" plainText="Create" />
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent="validateCreate">
        <div class="flex items-center">
          <label for="device-name" class="w-1/6 text-gray-600 font-bold">Device Name</label>
          <div class="relative text-gray-400 w-5/6">
            <input
              id="device-name"
              name="device-name"
              type="text"
              v-model="device.name"
              required=""
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
              placeholder="Device name (must be unique in each house)"
            />
          </div>
        </div>
        <div class="flex items-center">
          <label for="device-description" class="w-1/6 text-gray-600 font-bold">Description</label>
          <div class="relative text-gray-400 w-5/6">
            <input
              id="device-description"
              name="device-description"
              type="text"
              v-model="device.description"
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
          <label for="device-type" class="w-1/6 text-gray-600 font-bold">Type</label>
          <select class="py-3.5 border-gray-300 rounded-md text-sm w-5/6" v-model="device.type" required="">
            <option disabled value="">-- Please select a type --</option>
            <option v-for="option in deviceTypes" v-bind:value="option" v-bind:key="option">
              {{ option }}
            </option>
          </select>
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
            Create
          </button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";
import NavigationBar from "@/components/layouts/NavigationBar.vue";

export default {
  components: {
    NavigationBar
  },
  data() {
    return {
      device: {
        name: '',
        type: '',
        description: ''
      },
      configStr: '',
      deviceTypes: constants.deviceTypes
    };
  },
  methods: {
    validateCreate() {
      if (this.device.name && this.device.type && this.device.description) {
        try {
          this.device.config = JSON.parse(this.configStr);
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
      // POST request to create device
      fetch(
        constants.server + "/api/device/create", // endpoint
        httpReq.post({ ...this.device, house_id: localStorage.getItem('house_id') })
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
          alert("Device creation error: " + error);
        });
    },
    cancel() {
      this.$router.back();
    },
  },
};
</script>