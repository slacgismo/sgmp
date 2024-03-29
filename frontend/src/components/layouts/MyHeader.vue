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
    <div class="flex items-center space-x-1">
      <h1 class="text-2xl py-4 text-gray-800">
        Smart Grid Management Platform
      </h1>
      <svg
        xmlns="http://www.w3.org/2000/svg"
        class="h-4 w-4"
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
      <div v-if="isAdmin">
        <button
          class="text-2xl text-red-900 hover:underline"
          :key="house"
          @click="TogglePopup()"
        >
          {{ house }}
        </button>
        <popup v-if="popupTriggers" :TogglePopup="() => TogglePopup()"> </popup>
      </div>
      <div v-else>
        <h2 class="text-2xl text-red-900">{{ house }}</h2>
      </div>
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
        <span>{{ username }}</span>
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
              <router-link
                :to="{ name: 'profile' }"
                :class="[
                  active ? 'bg-gray-100' : '',
                  'block px-4 py-2 text-sm text-gray-700',
                ]"
                >My Profile</router-link
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
import { ref, computed } from "vue";
import { Menu, MenuButton, MenuItems, MenuItem } from "@headlessui/vue";
import Popup from "@/components/popup/HouseSwitchPopup.vue";
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
  setup() {
    const isAdmin = computed(() => {
      return sessionStorage.getItem("roles") == constants.roles.Admin;
    });
    const popupTriggers = ref(false);
    const TogglePopup = () => {
      popupTriggers.value = !popupTriggers.value;
    };
    return {
      isAdmin,
      popupTriggers,
      TogglePopup,
    };
  },
  data() {
    return {
      username: "Hello!",
      house: "",
      houseList: {},
    };
  },
  watch: {
    username: {
      immediate: true,
      handler() {
        this.username = sessionStorage.username;
      },
    }
  },
  created() {
    this.house = sessionStorage.getItem("house_desc");

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
    getAvatar() {
      let name = this.username;
      if (!name) {
        name = "";
      }
      return `https://ui-avatars.com/api/?name=` + name + `&background=random`;
    },
    logout() {
      let users = JSON.parse(localStorage.getItem("users"));
      let newUsers = [];
      for (let i = 0; i < users.length; i++) {
        let thisUser = users.pop();
        if (thisUser.email != sessionStorage.getItem("email")) {
          newUsers.push(thisUser);
        }
      }
      if (newUsers.length > 0) {
        localStorage.setItem("users", JSON.stringify(newUsers));
      } else {
        localStorage.clear();
      }

      sessionStorage.clear();
    },
  },
};
</script>
