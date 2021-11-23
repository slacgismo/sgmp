<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Create Role</h2>
    <navigation-bar naviText="Roles" routePath="/roles" plainText="Create" />
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <form class="space-y-4" @submit.prevent="validateCreate">
        <div class="flex items-center">
          <label for="role" class="w-1/6 text-gray-600 font-bold">Role</label>
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
                  d="M22 14.25l-6.75 6.75-2.25-2.25-1.5 1.5 3.75 3.75 8.25-8.25z"
                ></path>
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M10.5 19h7.5v-2.698c-1.575-0.919-3.663-1.549-6-1.74v-1.237c1.652-0.931 3-3.252 3-5.574 0-3.728 0-6.75-4.5-6.75s-4.5 3.022-4.5 6.75c0 2.322 1.348 4.643 3 5.574v1.237c-5.088 0.416-9 2.916-9 5.939h10.5v-1.5z"
                ></path>
                />
              </svg>
            </span>
            <input
              id="role"
              name="role"
              type="name"
              v-model="role"
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
              placeholder="Role"
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
</template>

<script>
import NavigationBar from "@/components/layouts/NavigationBar.vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: {
    NavigationBar
  },
  mounted() {
    this.getRoles();
  },
  data() {
    return {
      role: "",
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
      if (this.role) {
        return true;
      }
      return false;
    },
    saveChange() {
      if (!this.validateCreate()) {
        return;
      }
      // POST request to create role
      fetch(
        constants.server + "/api/role/create", // endpoint
        httpReq.post({ role: this.role }) // requestOptions
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.$router.push("/roles");
        })
        .catch((error) => {
          this.errorMessage = error;
          alert("Role creation error: " + error);
        });
    },
    cancel() {
      this.$router.back();
    },
  },
};
</script>