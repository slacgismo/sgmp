<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Create House</h2>
    <navigation-bar naviText="Houses" routePath="/houses" plainText="Update" />
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent>
        <div class="flex items-center">
          <label for="house-name" class="w-1/6 text-gray-600 font-bold">House Name</label>
          <div class="relative text-gray-400 w-5/6">
            <input
              id="house-name"
              name="house-name"
              type="text"
              v-model="house.name"
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
              placeholder="House name (must be unique in each house)"
            />
          </div>
        </div>

        <div class="flex items-center">
          <label for="house-description" class="w-1/6 text-gray-600 font-bold">Description</label>
          <div class="relative w-5/6">
            <input
              id="house-description"
              name="house-description"
              type="text"
              v-model="house.description"
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

  <generic-popup v-show="showCredentials" popup-title="Device Credentials" :togglePopup="() => confirmCredentials()" :showClose="true">
    Please copy the following credentials and paste it to the edge device. You will only be able to view the credentials once.<br />
    Make sure the credentials are saved before closing this window.
    <textarea
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
          font-mono"
      disabled>{{ createHouseResponse }}</textarea>
  </generic-popup>

  <generic-popup v-show="showLoading" :showNo="false" :showYes="false">
    <loading />
  </generic-popup>
</template>

<script>
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";
import NavigationBar from "@/components/layouts/NavigationBar.vue";
import GenericPopup from "@/components/popup/GenericPopup.vue";
import Loading from "@/components/Loading.vue";

export default {
  components: {
    NavigationBar,
    GenericPopup,
    Loading
  },
  mounted() {
  },
  data() {
    return {
      house: {
        name: '',
        description: ''
      },
      createHouseResponse: '',
      showCredentials: false,
      showLoading: false
    };
  },
  methods: {
    confirmCredentials() {
      this.$router.push("/houses");
    },
    validateCreate() {
      if (this.house.description && this.house.name) {
        return true;
      }
      return false;
    },
    saveChange() {
      if (!this.validateCreate()) {
        return;
      }
      // POST request to update house
      this.showLoading = true;
      fetch(
        constants.server + "/api/house/create", // endpoint
        httpReq.post(this.house)
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.showLoading = false;
          this.createHouseResponse = JSON.stringify(data);
          this.showCredentials = true;
        })
        .catch((error) => {
          this.showLoading = false;
          this.errorMessage = error;
          alert("House creation error: " + error);
        });
    },
    cancel() {
      this.$router.back();
      return true;
    },
  },
};
</script>