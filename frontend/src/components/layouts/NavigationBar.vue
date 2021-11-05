<template>
    <div id="test" class="flex items-center space-x-1 text-xs">
      <router-link to="/" class="font-bold text-indigo-700">Home</router-link>
      <svg
        v-if="naviText"
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
      <router-link v-if="naviText" :to="routePath" class="font-bold text-indigo-700">{{ naviText }}</router-link>
      <svg
        v-if="plainText"
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
      <span v-if="plainText" class="text-gray-600">{{ plainText }}</span>
    </div>
</template>

<script>

export default {
  name: "NavigationBar",
  props: {
    naviText: String,
    routePath: String,
    plainText: String
  },
  watch: {
    naviText: {
      immediate: true,
      handler() {
        document.naviText = this.naviText;
      },
    },
    routePath: {
      immediate: true,
      handler() {
        document.routePath = this.routePath;
      },
    },
    plainText: {
      immediate: true,
      handler() {
        document.plainText = this.plainText;
      },
    }
  }
}
</script>