<template>
  <div
    class="
      fixed
      inset-0
      z-50
      bg-gray-400 bg-opacity-50
      flex
      items-center
      justify-center
    "
  >
    <div class="rounded-md bg-white p-8 max-w-screen-sm">
      <h1 class="text-2xl text-gray-800 mb-4 text-center">{{ popupTitle }}</h1>
      <slot>

      </slot>
      <div class="flex mt-8 justify-around" v-if="showButtons">
        <button
          class="px-4 py-2 w-24 text-sm text-white rounded-md bg-red-900 hover:bg-red-700"
          @click="close()"
          v-show="showClose"
        >
          Close
        </button>

        <button
          class="px-4 py-2 w-24 text-sm text-white rounded-md bg-gray-400 hover:bg-gray-300"
          @click="close()"
          v-show="showNo"
        >
          No
        </button>
        <button
          class="ml-4 px-4 py-2 w-24 text-sm text-white rounded-md bg-red-900 hover:bg-red-700"
          @click="yes()"
          v-show="showYes"
        >
          Yes
        </button>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  components: {},
  props: {
    togglePopup: {
      default: () => {},
      type: Function
    },
    yesAction: {
      default: () => {},
      type: Function
    },
    popupTitle: {
      default: '',
      type: String
    },
    showClose: {
      default: false,
      type: Boolean
    },
    showNo: {
      default: false,
      type: Boolean
    },
    showYes: {
      default: false,
      type: Boolean
    }
  },
  data() {
    return {
      visible: false,
      showButtons: this.showClose || this.showNo || this.showYes
    };
  },
  setup() {
  },
  created() {
    
  },
  methods: {
    close() {
      this.togglePopup();
    },
    yes() {
      this.yesAction();
    }
  },
};
</script>