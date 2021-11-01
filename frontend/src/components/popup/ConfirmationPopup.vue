<template>
  <div
    class="
      fixed
      inset-0
      z-50
      bg-gray-400 bg-opacity-50
      flex
      items-center
      justify-center
    "
  >
    <div class="rounded-md bg-white p-8">
      <slot>
        <h1 class="text-2xl text-gray-800 whitespace-pre">{{ title }}</h1>
        <div class="flex justify-around mt-8">
          <button
            class="
              px-4
              py-2
              w-24
              text-sm text-white
              rounded-md
              bg-gray-400
              hover:bg-gray-300
            "
            @click="TogglePopup()"
          >
            No
          </button>
          <button
            class="
              px-4
              py-2
              w-24
              text-sm text-white
              rounded-md
              bg-red-900
              hover:bg-red-700
            "
            @click="confirm()"
          >
            Yes
          </button>
        </div>
      </slot>
    </div>
  </div>
</template>

<script>
import { ref } from "vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  props: {
    TogglePopup: Function,
    title: String,
    request: Object
  },
  setup() {
    const selected = ref(false);
    return {
      selected,
    };
  },
  watch: {
    title: {
      immediate: true,
      handler() {
        document.title = this.title;
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
    confirm() {
      // POST request to change the house selection
      fetch(
        constants.server + "/api/user/delete", // endpoint
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
          this.$router.go(); // reload page
        })
        .catch((error) => {
          this.errorMessage = error;
          console.error(error);
        });
      this.TogglePopup();
    },
  },
};
</script>