<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Update User</h2>

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
      <router-link to="/users" class="font-bold text-indigo-700">Users</router-link>
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
      <form class="space-y-4" @submit.prevent="validateUpdate">
        <div class="flex items-center">
          <label for="email" class="w-1/6 text-gray-600 font-bold">Email</label>
          <div class="relative text-gray-400 w-5/6">
            <span class="relative w-5/6 font-mono">
              {{ user.email }}
            </span>
          </div>
        </div>

        <div class="flex items-center">
          <label for="username" class="w-1/6 text-gray-600 font-bold"
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
              id="username"
              name="username"
              type="username"
              autocomplete="current-username"
              v-model="user.name"
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
          <select class="py-3.5 border-gray-300 rounded-md text-sm w-5/6" v-model="user.role" required="">
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
            Update
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
import HouseInput from "@/components/HouseInput.vue";
import GenericPopup from '@/components/popup/GenericPopup.vue';
import Loading from '@/components/Loading.vue';
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: {
    HouseInput,
    GenericPopup,
    Loading
  },
  mounted() {
    this.getRoles();
    this.getUserProfile();
  },
  data() {
    return {
      user: {
        email: this.$route.params.email,
        name: "",
        role: "",
        house_id: ""
      },
      showLoadingPopup: false,
      roleOptions: [],
      selectedHouse: {}
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
    getUserProfile() {
      // Fetch data for the user profile
      fetch(
        constants.server + "/api/user/profile", // endpoint
        httpReq.post({ email: this.$route.params.email }) // requestOptions
      )
      .then(async response => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }

        this.user.name = data.profile.name;
        this.user.role = data.profile.roles.toString();
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
    },
    validateUpdate() {
      if (this.username && this.email && this.role && this.selectedHouse.house_id) {
        return true;
      }
      return false;
    },
    saveChange() {
      if (!this.validateUpdate()) {
        return;
      }
      // POST request to create user
      fetch(
        constants.server + "/api/user/create", // endpoint
        httpReq.post({
          // requestOptions
          "email": this.email,
          "name": this.username,
          "role": this.role,
          "house_id": this.selectedHouse.house_id.toString()
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
          this.$router.push("/users");
        })
        .catch((error) => {
          this.errorMessage = error;
          alert("User creation error: " + error);
        });
    },
    cancel() {
      this.$router.back();
    },
  },
};
</script>