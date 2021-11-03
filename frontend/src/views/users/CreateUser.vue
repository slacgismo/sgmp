<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Create User</h2>
    <navigation-bar naviText="Users" routePath="/users" plainText="Create" />
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent="validateCreate">
        <div class="flex items-center">
          <label for="email" class="w-1/6 text-gray-600 font-bold">Email</label>
          <div class="relative text-gray-400 w-5/6">
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
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
            </span>
            <input
              id="email"
              name="email"
              type="email"
              autocomplete="email"
              v-model="email"
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
              placeholder="Email address"
              required=""
            />
          </div>
        </div>

        <div class="flex items-center">
          <label for="name" class="w-1/6 text-gray-600 font-bold"
            >Name</label
          >
          <div class="relative text-gray-400 w-5/6">
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
                  d="M12 16.561v-1.237c1.652-0.931 3-3.252 3-5.574 0-3.728 0-6.75-4.5-6.75s-4.5 3.022-4.5 6.75c0 2.322 1.348 4.643 3 5.574v1.237c-5.088 0.416-9 2.916-9 5.939h21c0-3.023-3.912-5.523-9-5.939z"
                />
              </svg>
            </span>
            <input
              id="name"
              name="name"
              type="name"
              autocomplete="current-name"
              v-model="name"
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
              placeholder="User name"
            />
          </div>
        </div>

        <div class="flex items-center">
          <label for="role" class="w-1/6 text-gray-600 font-bold">Role</label>
          <select class="py-3.5 border-gray-300 rounded-md text-sm w-5/6" v-model="role" required="">
            <option disabled value="">-- Please select a role --</option>
            <option v-for="option in roleOptions" v-bind:value="option">
              {{ option }}
            </option>
          </select>
        </div>

        <div class="flex items-center">
          <label for="house" class="w-1/6 text-gray-600 font-bold">House</label>
          <house-input
            id="house"
            ref="houseInput"
            class="w-5/6"
            @onItemSelected="selectedHouse = $event"
            @onItemReset="selectedHouse = {}"
          />
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
  <generic-popup v-show="createResult" :popup-title="createResult" :togglePopup="() => createCallBack()"  :showClose="true" />
</template>

<script>
import HouseInput from "@/components/HouseInput.vue";
import NavigationBar from "@/components/layouts/NavigationBar.vue";
import GenericPopup from "@/components/popup/GenericPopup.vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: {
    HouseInput,
    NavigationBar,
    GenericPopup
  },
  mounted() {
    this.getRoles();
  },
  data() {
    return {
      email: "",
      name: "",
      role: "",
      roleOptions: [],
      selectedHouse: {},
      createResult: ""
    };
  },
  methods: {
    getRoles() {
      // GET request to fetch data for the role selection
      fetch(
        constants.server + "/api/role/list",
        httpReq.get() // requestOptions
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }

          this.roleOptions = data.role_list;
        })
        .catch((error) => {
          this.errorMessage = error;
          console.error(error);
        });
    },
    validateCreate() {
      if (!this.$refs.houseInput.validate()) {
        return false;
      }
      if (this.name && this.email && this.role && this.selectedHouse.house_id) {
        return true;
      }
      return false;
    },
    saveChange() {
      if (!this.validateCreate()) {
        return;
      }
      // POST request to create user
      fetch(
        constants.server + "/api/user/create", // endpoint
        httpReq.post({
          // requestOptions
          "email": this.email,
          "name": this.name,
          "role": this.role,
          "house_id": this.selectedHouse.house_id.toString()
        })
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok || data.status != "ok") {
            // get error message from body or default to response status
            const error = (data && data.message) || data.status || response.status;
            return Promise.reject(error);
          }
          this.createResult = "Creation complete!";
        })
        .catch((error) => {
          this.errorMessage = error;
          this.createResult = "Error: " + error;
        });
    },
    cancel() {
      this.$router.back();
    },
    createCallBack() {
      this.createResult = "";
      this.$router.push("/users");
    }
  },
};
</script>