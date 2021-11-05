<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Create Analytics</h2>
    <navigation-bar naviText="Analytics" routePath="/analytics" plainText="Create" />
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent="validateCreate">
        <div class="flex items-center">
          <label for="analytics-name" class="w-1/6 text-gray-600 font-bold">Analytics Name</label>
          <div class="relative text-gray-400 w-5/6">
            <input
              id="analytics-name"
              name="analytics-name"
              type="text"
              v-model="analytics.name"
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
              placeholder="Analytics name (must be unique in each house)"
            />
          </div>
        </div>
        <div class="flex items-center">
          <label for="analytics-description" class="w-1/6 text-gray-600 font-bold">Description</label>
          <div class="relative text-gray-400 w-5/6">
            <input
              id="analytics-description"
              name="analytics-description"
              type="text"
              v-model="analytics.description"
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
          <label for="analytics-formula" class="w-1/6 text-gray-600 font-bold">Formula</label>
          <div class="relative text-gray-400 w-5/6">
            <input
              id="analytics-formula"
              name="analytics-formula"
              type="text"
              v-model="analytics.formula"
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
                font-mono
              "
              placeholder="Formula"
              required=""
            />
          </div>
        </div>
        <div class="flex items-center">
          <label class="w-1/6 text-gray-600 font-bold">Continuous Aggregation</label>
          <div class="relative text-gray-400 w-5/6">
            <input
                v-model="analytics.continuous_aggregation"
                :value="false"
                type="radio"
                id="ca-false"
                class="h-5 w-5 text-blue-500 border-gray-300 rounded-full cursor-pointer focus:ring-0"
              /><label class="py-5 text-gray-500" for="ca-false"> Disabled&nbsp;</label>
            <input
                v-model="analytics.continuous_aggregation"
                :value="true"
                type="radio"
                id="ca-true"
                class="h-5 w-5 text-blue-500 border-gray-300 rounded-full cursor-pointer focus:ring-0"
              /><label class="py-5 text-gray-500" for="ca-true"> Enabled</label>
          </div>
        </div>
        <div class="flex items-center">
          <label class="w-1/6 text-gray-600 font-bold">&nbsp;</label>
          <div class="relative text-gray-400 w-5/6 text-gray-500">
            Please note that enabling Continuous Aggregation on a large amount of data can take up to 5 minutes per new identifier in the formula.
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

  <generic-popup v-show="showLoadingPopup">
      <loading />
  </generic-popup>
</template>

<script>
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";
import GenericPopup from '@/components/popup/GenericPopup.vue';
import Loading from '@/components/Loading.vue';
import NavigationBar from "@/components/layouts/NavigationBar.vue";

export default {
  components: {
      GenericPopup,
      Loading,
      NavigationBar
  },
  mounted() {},
  data() {
    return {
      analytics: {
        name: '',
        description: '',
        formula: '',
        continuous_aggregation: false
      },
      showLoadingPopup: false
    };
  },
  methods: {
    validateCreate() {
      if (this.analytics.name && this.analytics.description && this.analytics.formula) {
        return true;
      }
      return false;
    },
    saveChange() {
      if (!this.validateCreate()) {
        return;
      }
      this.showLoadingPopup = true;
      // POST request to create analytics
      fetch(
        constants.server + "/api/analytics/create", // endpoint
        httpReq.post({ ...this.analytics, house_id: localStorage.getItem('house_id') })
      )
        .then(async (response) => {
          this.showLoadingPopup = false;
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.$router.push("/analytics");
        })
        .catch((error) => {
          this.errorMessage = error;
          alert("Analytics creation error: " + error);
        });
    },
    cancel() {
      this.$router.back();
    },
  },
};
</script>