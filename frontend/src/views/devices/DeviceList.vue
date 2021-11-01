<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">Device List</h2>

    <div class="flex items-center space-x-1 text-xs">
      <router-link to="/" class="font-bold text-indigo-700">Home</router-link>
      <svg xmlns="http://www.w3.org/2000/svg" class="h-2 w-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
      </svg>
      <span class="text-gray-600">Devices</span>
    </div>
  </div>

  <div class="p-4 mt-8 sm:px-8 sm:py-4">
    <div class="p-4 bg-white rounded">
      <div class="flex justify-between">
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
              focus:outline-none focus:ring-gray-500 focus:ring-gray-500 focus:z-10
            "
            placeholder="Search device"
          />
        </div>
        <div>
          <Menu as="div" class="relative inline-block text-left">
            <div>
              <MenuButton
                class="
                  inline-flex
                  justify-center
                  w-full
                  px-4
                  py-2
                  text-sm
                  font-medium
                  text-white
                  rounded-md
                  bg-gray-400
                  hover:bg-gray-300
                  focus:outline-none
                  focus-visible:ring-2 focus-visible:ring-white focus-visible:ring-opacity-75
                "
              >
                Actions
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-5 h-5 ml-2 -mr-1 text-violet-200 hover:text-violet-100"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </MenuButton>
            </div>

            <transition
              enter-active-class="transition duration-100 ease-out"
              enter-from-class="transform scale-95 opacity-0"
              enter-to-class="transform scale-100 opacity-100"
              leave-active-class="transition duration-75 ease-in"
              leave-from-class="transform scale-100 opacity-100"
              leave-to-class="transform scale-95 opacity-0"
            >
              <MenuItems
                class="
                  absolute
                  right-0
                  w-32
                  mt-1
                  origin-top-right
                  bg-white
                  divide-y divide-gray-100
                  rounded-md
                  shadow-lg
                  ring-1 ring-black ring-opacity-5
                  z-50
                  focus:outline-none
                "
              >
                <div class="px-1 py-1">
                  <MenuItem v-slot="{ active }">
                    <router-link v-slot="{ navigate }" :to="{ name: 'createdevice' }">
                      <button
                        @click="navigate"
                        :class="[
                          active ? 'bg-gray-400 text-white' : 'text-gray-900',
                          'group flex rounded-md items-center w-full px-2 py-2 text-sm',
                        ]"
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
                  </MenuItem>
                  <MenuItem v-slot="{ active }">
                    <button
                      :class="[
                        active ? 'bg-red-800 text-white' : 'text-gray-900',
                        'group flex rounded-md items-center w-full px-2 py-2 text-sm',
                      ]"
                      @click="confirmDelete()"
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
                  </MenuItem>
                </div>
              </MenuItems>
            </transition>
          </Menu>
        </div>
      </div>
      <table class="w-full mt-2 text-gray-500">
        <thead class="border-b">
          <tr>
            <th class="p-2 text-left text-gray-600">
              <input
                v-model="selectAll"
                type="checkbox"
                class="h-5 w-5 text-blue-500 border-gray-300 rounded cursor-pointer focus:ring-0"
              />
            </th>
            <th class="text-left text-gray-600">Name</th>
            <th class="text-left text-gray-600">Type</th>
            <th class="text-left text-gray-600">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="device in deviceList" :key="device.device_id">
            <td class="p-2">
              <input
                type="checkbox"
                class="h-5 w-5 text-blue-500 border-gray-300 rounded cursor-pointer focus:ring-0"
                :value="device.device_id"
                v-model="deleteChecked"
              />
            </td>
            <td><router-link :to="{ name: 'updatedevice', params: { id: device.device_id } }">{{ device.name }}</router-link></td>
            <td>{{ device.type }}</td>
            <td>{{ device.description }}</td>
          </tr>
          <tr v-show="deviceList.length === 0 && !deviceListLoading">
            <td colspan="4" class="p-2">No device.</td>
          </tr>
          <tr v-show="deviceListLoading">
            <td colspan="4" class="py-4"><loading /></td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="4" class="py-2">
              <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                  <p class="text-sm text-gray-500">
                    Page
                    <span class="font-medium underline">1</span>
                    of
                    <span class="font-medium">{{ this.deviceList.length }}</span>
                  </p>
                </div>
                <div>
                  <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
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
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
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
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
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
  <generic-popup v-show="showDeleteConfirm" popup-title="Delete Devices" :togglePopup="() => confirmDelete()" :yesAction="() => performDelete()" :showNo="true" :showYes="true">
    Are you sure to delete the following devices?
    <br /><pre v-for="id in deleteChecked" :key="id">{{ deviceIdNameMap[id] }}</pre>
  </generic-popup>
</template>

<script>
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/vue';
import { ref } from 'vue';
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";
import Loading from "@/components/Loading.vue";
import GenericPopup from "@/components/popup/GenericPopup.vue";

export default {
  components: {
    Menu,
    MenuButton,
    MenuItems,
    MenuItem,
    Loading,
    GenericPopup
  },
  setup() {
  },
  data() {
    return {
      deviceList: [],
      deleteChecked: [],
      deviceIdNameMap: {},
      deviceListLoading: true,
      showDeleteConfirm: false,
    }
  },
  mounted() {
    this.loadDevices();
  },
  setup() {
  },
  methods: {
    loadDevices: function () {
      // Fetch data for the device list
      fetch(
          constants.server + "/api/device/list", // endpoint
          httpReq.post({ house_id: localStorage.getItem("house_id") }) // requestOptions
        )
        .then(async response => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.deviceIdNameMap = {};
          this.deviceList = data.devices;
          this.deviceListLoading = false;

          for (const device of data.devices) {
            this.deviceIdNameMap[device.device_id] = device.name;
          }
        })
        .catch(error => {
          this.errorMessage = error;
          console.error(error);
        });
    },
    confirmDelete: function() {
      if (this.showDeleteConfirm) {
        this.showDeleteConfirm = false;
        return;
      }
      if (this.deleteChecked.length > 0) this.showDeleteConfirm = true;
    },
    performDelete: function() {
      let promises = [];
      for (const id of this.deleteChecked) {
        promises.push(fetch(
            constants.server + "/api/device/delete", // endpoint
            httpReq.post({ device_id: id }) // requestOptions
          )
          .then(async response => {
            const data = await response.json();

            // check for error response
            if (!response.ok) {
              // get error message from body or default to response status
              const error = (data && data.message) || response.status;
              return Promise.reject(error);
            }
          }));
      }

      Promise.all(promises).then(() => {
        alert('Deletion complete.');
        this.showDeleteConfirm = false;
        this.deviceIdNameMap = {};
        this.deviceList = {};
        this.deviceListLoading = true;

        this.loadDevices();
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
    }
  },
  computed: {
    selectAll: {
      get: function () {
        return this.deviceList ? this.deleteChecked.length == this.deviceList.length : false;
      },
      set: function (value) {
        var selected = [];

        if (value) {
          this.deviceList.forEach(function (device) {
            selected.push(device.device_id);
          });
        }

        this.deleteChecked = selected;
      }
    }
  }
}
</script>