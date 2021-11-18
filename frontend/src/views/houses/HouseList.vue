<template>
  <div class="flex justify-between px-4 mt-4 sm:px-8">
    <h2 class="text-2xl text-gray-600">House List</h2>
    <navigation-bar plainText="Houses" />
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
            placeholder="Search house"
            v-model="searchText"
          />
        </div>
        <div class="flex gap-4">
          <router-link v-slot="{ navigate }" :to="{ name: 'createhouse' }">
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

          <button
            class="
              w-24
              px-2
              py-2
              text-sm text-white
              rounded-md
              bg-red-900
              hover:bg-red-800
              disabled:bg-red-900 disabled:cursor-default
              group
              flex
              items-center
            "
            @click="confirmDelete()"
            :disabled="!this.deleteChecked.length"
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
            <th class="text-left text-gray-600">ID</th>
            <th class="text-left text-gray-600">Name</th>
            <th class="text-left text-gray-600">Description</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr v-for="house in computedList" :key="house.house_id">
            <td class="p-2">
              <input
                type="checkbox"
                class="h-5 w-5 text-blue-500 border-gray-300 rounded cursor-pointer focus:ring-0"
                :value="house.house_id"
                v-model="deleteChecked"
              />
            </td>
            <td>{{ house.house_id }}</td>
            <td><router-link :to="{ name: 'updatehouse', params: { id: house.house_id } }">{{ house.name }}</router-link></td>
            <td>{{ house.description }}</td>
          </tr>
          <tr v-show="houseList.length === 0 && !houseListLoading">
            <td colspan="4" class="p-2">No house.</td>
          </tr>
          <tr v-show="houseListLoading">
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
                    <span class="font-medium underline">{{ pageIndex + 1 }}</span>
                    of
                    <span class="font-medium">{{ maxPage }}</span>
                  </p>
                </div>
                <div>
                  <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                    <button
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
                        disabled:bg-white disabled:cursor-default
                      "
                      @click="updatePage(-1)"
                      :disabled="pageIndex == 0"
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
                    </button>
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
                      {{ pageIndex + 1 }}
                    </a>
                    <button
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
                        disabled:bg-white disabled:cursor-default
                      "
                      @click="updatePage(1)"
                      :disabled="pageIndex == maxPage - 1"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-6 w-6"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke="currentColor"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                      </svg>
                    </button>
                  </nav>
                </div>
              </div>
            </td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
  <generic-popup v-show="showDeleteConfirm" popup-title="Delete Houses" :togglePopup="() => confirmDelete()" :yesAction="() => performDelete()" :showNo="true" :showYes="true">
    Are you sure to delete the following houses?
    <br /><pre v-for="id in deleteChecked" :key="id">{{ houseIdNameMap[id] }}</pre>
  </generic-popup>
</template>

<script>
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/vue';
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";
import Loading from "@/components/Loading.vue";
import GenericPopup from "@/components/popup/GenericPopup.vue";
import NavigationBar from "@/components/layouts/NavigationBar.vue";

export default {
  components: {
    Menu,
    MenuButton,
    MenuItems,
    MenuItem,
    Loading,
    GenericPopup,
    NavigationBar
  },
  data() {
    return {
      houseList: [],
      deleteChecked: [],
      houseIdNameMap: {},
      houseListLoading: true,
      showDeleteConfirm: false,
      pageIndex: 0,
      maxPage: 0,
      numPerPage: constants.numPerPage,
      searchText: ""
    }
  },
  mounted() {
    this.loadHouses();
  },
  methods: {
    loadHouses: function () {
      // Fetch data for the house list
      fetch(
          constants.server + "/api/house/list", // endpoint
          httpReq.get() // requestOptions
        )
        .then(async response => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          this.houseIdNameMap = {};
          this.houseList = data.houses;
          this.maxPage = 1 + parseInt((data.houses.length - 1) / this.numPerPage);
          this.houseListLoading = false;

          for (const house of data.houses) {
            this.houseIdNameMap[house.house_id] = house.name;
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
            constants.server + "/api/house/delete", // endpoint
            httpReq.post({ house_id: id }) // requestOptions
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
        this.houseIdNameMap = {};
        this.houseList = {};
        this.houseListLoading = true;

        this.loadHouses();
      })
      .catch(error => {
        this.errorMessage = error;
        console.error(error);
      });
    },
    updatePage: function(offset) {
      var newIdx = this.pageIndex + offset;
      this.pageIndex = Math.min(Math.max(0, newIdx), this.maxPage - 1);
    }
  },
  computed: {
    selectAll: {
      get: function () {
        return this.houseList.length ? this.deleteChecked.length == this.houseList.length : false;
      },
      set: function (value) {
        var selected = [];

        if (value) {
          this.houseList.forEach(function (house) {
            selected.push(house.house_id);
          });
        }

        this.deleteChecked = selected;
      }
    },
    computedList: {
      get: function () {
        const startIdx = this.pageIndex * this.numPerPage;
        var list = this.houseList;
        if (this.searchText) {
          list = list.filter(item => 
            item.description.toLowerCase().includes(this.searchText.toLowerCase()));
        }
        this.maxPage = 1 + parseInt((list.length - 1) / this.numPerPage);
        return list.slice(startIdx, startIdx + this.numPerPage);
      }
    }
  }
}
</script>