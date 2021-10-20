<template>
  <header class="flex justify-between px-4 sm:px-6">
    <button class="sm:hidden">
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
          d="M4 6h16M4 12h16M4 18h16"
        />
      </svg>
    </button>
    <div class="flex">
      <h1 class="text-2xl px-2 py-4 text-gray-800">
        Smart Grid Management Platform
      </h1>
      <select
        class="
          w-32 h-auto
          space-x-2
          px-2
          py-4
          text-sm
          border-0 border-b-2 border-gray-200
          hover:border-red-900
        "
        @change="onChangeHome($event)"
      >
        <option
          :value="house.house_id"
          v-for="house in houseList"
          :key="house.house_id"
        >
          {{ house.description }}
        </option>
      </select>
    </div>

    <Menu as="div" class="relative">
      <MenuButton
        class="
          flex
          items-center
          space-x-2
          px-2
          py-4
          text-sm
          border-b-2 border-gray-200
          hover:border-red-900
        "
      >
        <img class="h-8 w-8 rounded-full" :src="getAvatar()" alt="" />
        <span>{{ getName() }}</span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M19 9l-7 7-7-7"
          />
        </svg>
      </MenuButton>
      <transition
        enter-active-class="transition ease-out duration-100"
        enter-from-class="transform opacity-0 scale-95"
        enter-to-class="transform opacity-100 scale-100"
        leave-active-class="transition ease-in duration-75"
        leave-from-class="transform opacity-100 scale-100"
        leave-to-class="transform opacity-0 scale-95"
      >
        <MenuItems
          class="
            origin-top-right
            absolute
            text-center
            right-0
            w-full
            shadow-lg
            bg-white
            ring-1 ring-black ring-opacity-5
            divide-y divide-gray-200
            focus:outline-none
          "
        >
          <div>
            <MenuItem v-slot="{ active }">
              <a
                href="#"
                :class="[
                  active ? 'bg-gray-100' : '',
                  'block px-4 py-2 text-sm text-gray-700',
                ]"
                >My Profile</a
              >
            </MenuItem>
            <MenuItem v-slot="{ active }">
              <a
                href="#"
                :class="[
                  active ? 'bg-gray-100' : '',
                  'block px-4 py-2 text-sm text-gray-700',
                ]"
                >Settings</a
              >
            </MenuItem>
          </div>
          <MenuItem v-slot="{ active }" v-on:click="logout()">
            <router-link
              :to="{ name: 'login' }"
              :class="[
                active ? 'bg-gray-100' : '',
                'block px-4 py-2 text-sm text-gray-700',
              ]"
              >Sign out</router-link
            >
          </MenuItem>
        </MenuItems>
      </transition>
    </Menu>
  </header>
</template>

<script>
import { Menu, MenuButton, MenuItems, MenuItem } from "@headlessui/vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: {
    Menu,
    MenuButton,
    MenuItems,
    MenuItem,
  },
  data() {
    return {
      houseList: {},
    };
  },
  created() {
    // POST request to fetch data for the houses
    fetch(
      constants.server + "/api/house/list", // endpoint
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

        if (data.houses) {
          this.houseList = data.houses;
        }
        // this.visible = true;
      })
      .catch((error) => {
        this.errorMessage = error;
        console.error(error);
      });
  },
  methods: {
    getName() {
      return localStorage.username ? localStorage.username : "Hello!";
    },
    getAvatar() {
      let name = localStorage.username;
      if (!name) {
        name = "";
      }
      return `https://ui-avatars.com/api/?name=` + name + `&background=random`;
    },
    logout() {
      localStorage.clear();
    },
    onChangeHome(event) {
      this.$data.houseId = parseInt(event.target.value);
    }
  },
};
</script>
