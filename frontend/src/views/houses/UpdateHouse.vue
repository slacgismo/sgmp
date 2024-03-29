<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Update House</h2>
    <navigation-bar naviText="Houses" routePath="/houses" plainText="Update" />
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent>
        <div class="flex items-center">
          <label for="house-name" class="w-1/6 text-gray-600 font-bold">House Name</label>
          <div class="relative w-5/6 font-mono">
            {{ name }}
          </div>
        </div>

        <div class="flex items-center">
          <label for="house-description" class="w-1/6 text-gray-600 font-bold">Description</label>
          <div class="relative w-5/6">
            <input
              id="house-description"
              name="house-description"
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
            @click="confirmSync()"
          >
            Synchronize Configuration
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
            @click="confirmGenerateKeys()"
          >
            Generate AWS Credentials
          </button>
        </div>
      </form>
    </div>
  </div>

  <generic-popup v-show="showGenerateKeysConfirm" popup-title="Generate Credentials" :togglePopup="() => confirmGenerateKeys()" :yesAction="() => generateKeys()" :showNo="true" :showYes="true">
    Are you sure to generate a new set of credentials for {{ name }}?<br />
    By doing so, the existing credentials will be revoked. Before the new credentials is uploaded to the edge device, it would not be able to publish any data!
  </generic-popup>

  <generic-popup v-show="showSyncConfirm" popup-title="Sync Configuration" :togglePopup="() => confirmSync()" :yesAction="() => sync()" :showNo="true" :showYes="true">
    Are you sure to synchronize the device configuration for house {{ name }}?
  </generic-popup>

  <generic-popup v-show="showLoading" :showNo="false" :showYes="false">
    <loading />
  </generic-popup>

  <generic-popup v-show="showGeneratedKeys" popup-title="Device Credentials" :togglePopup="() => toggleGeneratedKeys()" :showClose="true" :showNo="false" :showYes="false">
    Please copy this to the edge device:
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
      disabled>{{ credentials }}</textarea>
    Note that the credentials will only be shown once!
  </generic-popup>

  <generic-popup v-show="showSyncComplete" popup-title="Sync Configuration" :togglePopup="() => toggleSyncComplete()" :showClose="true" :showNo="false" :showYes="false">
    Successfully synchronized device configuration for house {{ name }}.
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
    // Fetch data for the house details
    fetch(
        constants.server + "/api/house/details", // endpoint
        httpReq.post({ house_id: this.$route.params.id }) // requestOptions
      )
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.name = data.house.name;
        this.description = data.house.description;
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
  },
  data() {
    return {
      name: '',
      description: '',
      showGenerateKeysConfirm: false,
      showGeneratedKeys: false,
      showLoading: false,
      showSyncConfirm: false,
      showSyncComplete: false,
      credentials: ''
    };
  },
  methods: {
    validateCreate() {
      if (this.description) {
        return true;
      }
      return false;
    },
    toggleGeneratedKeys() {
      this.showGeneratedKeys = !this.showGeneratedKeys;
    },
    confirmGenerateKeys() {
      this.showGenerateKeysConfirm = !this.showGenerateKeysConfirm;
    },
    confirmSync() {
      this.showSyncConfirm = !this.showSyncConfirm;
    },
    toggleSyncComplete() {
      this.showSyncComplete = !this.showSyncComplete;
    },
    generateKeys() {
      this.showGenerateKeysConfirm = false;
      this.showLoading = true;
      fetch(
        constants.server + '/api/house/generateKeys',
        httpReq.post({ house_id: this.$route.params.id })
      ).then(async (response) => {
        const data = await response.json();

        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.credentials = JSON.stringify(data);
        this.showGeneratedKeys = true;
        this.showLoading = false;
      });
    },
    sync() {
      this.showSyncConfirm = false;
      this.showLoading = true;
      fetch(
        constants.server + '/api/house/sync',
        httpReq.post({ house_id: this.$route.params.id })
      ).then(async (response) => {
        const data = await response.json();

        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.showSyncComplete = true;
        this.showLoading = false;
      });
    },
    saveChange() {
      if (!this.validateCreate()) {
        return;
      }
      // POST request to update house
      fetch(
        constants.server + "/api/house/update", // endpoint
        httpReq.post({ house_id: this.$route.params.id, description: this.description })
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.$router.push("/houses");
        })
        .catch((error) => {
          this.errorMessage = error;
          alert("House update error: " + error);
        });
    },
    cancel() {
      this.$router.back();
      return true;
    },
  },
};
</script>