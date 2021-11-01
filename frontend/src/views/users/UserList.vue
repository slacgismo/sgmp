<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">User List</h2>

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
      <span class="text-gray-600">Users</span>
    </div>
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <div class="p-1 flex justify-between">
        <div class="relative text-gray-400">
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
                d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
              />
            </svg>
          </span>
          <input
            id="search"
            name="search"
            type="search"
            class="
              w-full
              py-2
              text-sm text-gray-900
              rounded-md
              pl-10
              border border-gray-300
              focus:outline-none
              focus:ring-gray-500
              focus:ring-gray-500
              focus:z-10
            "
            placeholder="Search user"
          />
        </div>

        <div class="flex gap-4">
          <div v-if="selected.length > 0 || selectAll">
            <button
              class="
                w-24
                px-2
                py-2
                text-sm text-white
                rounded-md
                bg-red-900
                hover:bg-red-800
                group
                flex
                items-center
              "
              @click="TogglePopup()"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-5 h-5 mr-2 text-violet-400"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                />
              </svg>
              Delete
            </button>
            <popup
              :title="getConfirmMsg()"
              :request="getDeleteRequest()"
              v-if="popupTriggers"
              :TogglePopup="() => TogglePopup()"
            />
          </div>

          <router-link v-slot="{ navigate }" :to="{ name: 'createuser' }">
            <button
              @click="navigate"
              class="
                w-24
                px-2
                py-2
                text-sm text-white
                rounded-md
                bg-gray-400
                hover:bg-gray-300
                group
                flex
                items-center
              "
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="w-5 h-5 mr-2"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M12 6v6m0 0v6m0-6h6m-6 0H6"
                />
              </svg>
              Create
            </button>
          </router-link>
        </div>
      </div>
      <table class="w-full mt-2 text-gray-500">
        <thead class="border-b">
          <tr>
            <th class="p-2 text-left text-gray-600">
              <input
                v-model="selectAll"
                type="checkbox"
                class="
                  h-5
                  w-5
                  text-blue-500
                  border-gray-300
                  rounded
                  cursor-pointer
                  focus:ring-0
                "
              />
            </th>
            <th class="text-left text-gray-600">User</th>
            <th class="text-left text-gray-600">Role</th>
            <th class="text-left text-gray-600">House</th>
            <th class="text-left text-gray-600">Join Date</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="user in userList" :key="user.email">
            <td class="p-2">
              <input
                type="checkbox"
                :value="user.email"
                v-model="selected"
                class="
                  h-5
                  w-5
                  text-blue-500
                  border-gray-300
                  rounded
                  cursor-pointer
                  focus:ring-0
                "
                :checked="selectAll"
              />
            </td>
            <td class="flex items-center py-4">
              <img
                class="inline-block h-12 w-12 rounded-full ring-2 ring-white"
                :src="getAvatar(user.name)"
                alt=""
              />
              <div class="px-4">
                <div>
                  <a href="#" class="text-gray-600 font-bolder">{{
                    user.name
                  }}</a>
                </div>
                <div class="font-bold text-sm">
                  {{ user.email }}
                </div>
              </div>
            </td>
            <td>{{ user.role.toString() }}</td>
            <td>{{ user.house_description }}</td>
            <td>{{ formatDate(user.create_time) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="7" class="py-2">
              <div
                class="
                  hidden
                  sm:flex-1 sm:flex sm:items-center sm:justify-between
                "
              >
                <div>
                  <p class="text-sm text-gray-500">
                    Page
                    <span class="font-medium underline">1</span>
                    of
                    <span class="font-medium">{{ this.userList.length }}</span>
                  </p>
                </div>
                <div>
                  <nav
                    class="
                      relative
                      z-0
                      inline-flex
                      rounded-md
                      shadow-sm
                      -space-x-px
                    "
                    aria-label="Pagination"
                  >
                    <a
                      href="#"
                      class="
                        relative
                        inline-flex
                        items-center
                        px-2
                        rounded-l-md
                        border border-gray-300
                        text-sm
                        font-medium
                        text-gray-500
                        hover:bg-gray-50
                      "
                    >
                      <span class="sr-only">Previous</span>
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
                          d="M15 19l-7-7 7-7"
                        />
                      </svg>
                    </a>
                    <a
                      aria-current="page"
                      class="
                        border-gray-300
                        text-gray-500
                        relative
                        inline-flex
                        items-center
                        px-4
                        py-1
                        border
                        text-sm
                        font-medium
                      "
                    >
                      1
                    </a>
                    <a
                      href="#"
                      class="
                        relative
                        inline-flex
                        items-center
                        px-2
                        py-1
                        rounded-r-md
                        border border-gray-300
                        text-sm
                        font-medium
                        text-gray-500
                        hover:bg-gray-50
                      "
                    >
                      <span class="sr-only">Next</span>
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
                          d="M9 5l7 7-7 7"
                        />
                      </svg>
                    </a>
                  </nav>
                </div>
              </div>
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
import { Menu, MenuButton, MenuItems, MenuItem } from "@headlessui/vue";
import { ref } from "vue";
import Popup from "@/components/popup/ConfirmationPopup.vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: {
    Menu,
    MenuButton,
    MenuItems,
    MenuItem,
    Popup,
  },
  data() {
    return {
      userList: [],
      selected: [],
    };
  },
  setup() {
    const selectAll = ref(false);
    const popupTriggers = ref(false);
    const TogglePopup = () => {
      popupTriggers.value = !popupTriggers.value;
    };
    return {
      selectAll,
      popupTriggers,
      TogglePopup,
    };
  },
  mounted() {
    // GET request to fetch data for the user list
    fetch(
      constants.server + "/api/user/list", // endpoint
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

        this.userList = data.user_list;
      })
      .catch((error) => {
        this.errorMessage = error;
        console.error(error);
      });
  },
  methods: {
    formatDate(timestamp) {
      const options = {
        year: "numeric",
        month: "short",
        day: "numeric",
      };
      return `${new Date(timestamp).toLocaleDateString("en", options)}`;
    },
    formatDays(timestamp) {
      const msPerDay = 1000 * 60 * 60 * 24;
      let days = Math.floor((new Date() - new Date(timestamp)) / msPerDay);
      if (days >= 0) return `${days} days ago`;
      else return "-";
    },
    getAvatar(name) {
      if (!name) {
        name = "";
      }
      return `https://ui-avatars.com/api/?name=` + name + `&background=random`;
    },
    getConfirmMsg() {
      if (this.selectAll && this.selected.length != this.userList.length) {
        this.selected = [];
        for(let i = 0; i < this.userList.length; i++) {
          this.selected.push(this.userList[i].email);
        }
      }
      return "Are you sure to delete\n" + 
        this.selected.join("\n") + "?";
    },
    getDeleteRequest() {
      return {"email": this.selected.toString()};
    }
  },
};
</script>