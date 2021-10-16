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
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
      </svg>
    </button>
    <h1 class="text-2xl px-2 py-4 text-gray-800">Smart Grid Management Platform</h1>
    <Menu as="div" class="relative">
      <MenuButton class="flex items-center space-x-2 px-2 py-4 text-sm border-b-2 border-gray-200 hover:border-red-900">
        <img class="h-8 w-8 rounded-full" :src="getAvatar()" alt="" />
        <span>{{ getName() }}</span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-4 w-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
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
              <a href="#" :class="[active ? 'bg-gray-100' : '', 'block px-4 py-2 text-sm text-gray-700']"
                >My Profile</a
              >
            </MenuItem>
            <MenuItem v-slot="{ active }">
              <a href="#" :class="[active ? 'bg-gray-100' : '', 'block px-4 py-2 text-sm text-gray-700']">Settings</a>
            </MenuItem>
          </div>
          <MenuItem v-slot="{ active }" v-on:click="logout()">
            <router-link
              :to="{ name: 'login' }"
              :class="[active ? 'bg-gray-100' : '', 'block px-4 py-2 text-sm text-gray-700']"
              >Sign out</router-link>
          </MenuItem>
        </MenuItems>
      </transition>
    </Menu>
  </header>
</template>

<script>
import { Menu, MenuButton, MenuItems, MenuItem } from '@headlessui/vue'

export default {
  components: {
    Menu,
    MenuButton,
    MenuItems,
    MenuItem
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
      return `https://ui-avatars.com/api/?name=` + name + `&background=random`
    },
    logout() {
      localStorage.clear();
    }
  }
}
</script>
