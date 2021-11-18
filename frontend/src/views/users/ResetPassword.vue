<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Reset Password</h2>
    <navigation-bar naviText="Users" routePath="/users" plainText="Reset Password" />
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent="validateUpdate">
        <div class="flex items-center">
          <label for="email" class="w-1/4 text-gray-600 font-bold">Email</label>
          <div class="relative text-gray-400 w-3/4">
            <span class="relative font-mono">
              {{ email }}
            </span>
          </div>
        </div>

        <div class="flex items-center">
          <label for="username" class="w-1/4 text-gray-600 font-bold"
            >Current Password</label
          >
          <div class="relative text-gray-400 w-3/4">
            <span class="absolute inset-y-0 left-0 flex items-center pl-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
            </span>
            <input
              id="current-password"
              name="current-password"
              type="password"
              autocomplete="current-password"
              v-model="oldPassword"
              required=""
              class="
                w-full
                py-4
                text-sm text-gray-900
                rounded-md
                pl-10
                border border-gray-300
                focus:outline-none
                focus:ring-blue-500
                focus:border-blue-500
                focus:z-10
              "
              placeholder="Current Password"
            />
          </div>
        </div>
        <div class="flex items-center">
          <label for="username" class="w-1/4 text-gray-600 font-bold"
            >New Password</label
          >
          <div class="relative text-gray-400 w-3/4">
            <span class="absolute inset-y-0 left-0 flex items-center pl-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
            </span>
            <input
              id="new-password"
              name="new-password"
              type="password"
              autocomplete="new-password"
              v-model="newPassword"
              required=""
              class="
                w-full
                py-4
                text-sm text-gray-900
                rounded-md
                pl-10
                border border-gray-300
                focus:outline-none
                focus:ring-blue-500
                focus:border-blue-500
                focus:z-10
              "
              placeholder="New Password"
            />
          </div>
        </div>
        <div class="flex items-center">
          <label for="username" class="w-1/4 text-gray-600 font-bold"
            >Confirm New Password</label
          >
          <div class="relative text-gray-400 w-3/4">
            <span class="absolute inset-y-0 left-0 flex items-center pl-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
                />
              </svg>
            </span>
            <input
              id="confirm-password"
              name="confirm-password"
              type="password"
              autocomplete="confirm-password"
              v-model="confirmPassword"
              required=""
              class="
                w-full
                py-4
                text-sm text-gray-900
                rounded-md
                pl-10
                border border-gray-300
                focus:outline-none
                focus:ring-blue-500
                focus:border-blue-500
                focus:z-10
              "
              placeholder="Confirm New Password"
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
        </div>
      </form>
    </div>
  </div>
  <generic-popup v-show="showLoadingPopup">
      <loading />
  </generic-popup>

  <generic-popup v-show="updateResult" :popup-title="updateResult" :togglePopup="() => updateCallBack()"  :showClose="true" />
</template>

<script>
import { computed } from "vue";
import GenericPopup from "@/components/popup/GenericPopup.vue";
import Loading from "@/components/Loading.vue";
import NavigationBar from "@/components/layouts/NavigationBar.vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: {
    GenericPopup,
    Loading,
    NavigationBar,
  },
  data() {
    return {
      email: sessionStorage.getItem("email"),
      showLoadingPopup: false,
      oldPassword: "",
      newPassword: "",
      confirmPassword: "",
      updateResult: "",
    };
  },
  methods: {
    validateUpdate() {
      if (
        this.oldPassword &&
        this.newPassword &&
        this.confirmPassword
      ) {
        if (this.newPassword != this.confirmPassword) {
          this.confirmPassword = "";
          return false;
        }
        return true;
      }
      return false;
    },
    saveChange() {
      if (!this.validateUpdate()) {
        return;
      }
      // POST request to update user password
      fetch(
        constants.server + "/api/user/updatePassword", // endpoint
        httpReq.post({
          "old_password": this.oldPassword,
          "new_password": this.newPassword,
        })
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.updateResult = "Password updated!";
        })
        .catch((error) => {
          this.errorMessage = error;
          this.updateResult = "Reset error: " + error;
        });
    },
    cancel() {
      this.$router.back();
    },
    updateCallBack() {
      this.updateResult = "";
      this.$router.go();
    },
  },
};
</script>