
<template>
  <div class="relative mx-auto">
    <span
      class="absolute inset-y-0 left-0 flex items-center pl-2 text-gray-400"
    >
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
          d="M24 14.25l-4.5-4.5v-6.75h-3v3.75l-4.5-4.5-12 12v0.75h3v7.5h7.5v-4.5h3v4.5h7.5v-7.5h3z"
        />
      </svg>
    </span>
    <input
      v-if="Object.keys(selectedItem).length === 0"
      ref="dropdowninput"
      v-model.trim="inputValue"
      class="
        w-full
        py-3.5
        pl-10
        text-gray-900 text-sm
        rounded-md
        border border-gray-300
        focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10
      "
      type="text"
      required=""
      placeholder="Search house by ID or description"
    />
    <div
      v-else
      @click="resetSelection"
      class="
        w-full
        px-4
        py-3.5
        pl-10
        text-gray-900 text-sm
        rounded-md
        border border-gray-300
        focus:outline-none focus:ring-blue-500 focus:border-blue-500 focus:z-10
      "
    >
      {{ selectedItem.description }}
    </div>
    <div
      v-show="inputValue && loaded"
      class="absolute w-full mt-1 overflow-y-auto bg-white shadow-lg rounded-lg"
    >
      <div
        @click="selectItem(item)"
        v-show="itemVisible(item)"
        v-for="item in itemList"
        :key="item.house_id"
        class="
          flex
          justify-between
          w-full
          px-4
          py-3.5
          pl-10
          cursor-pointer
          text-gray-900
          hover:bg-gray-100
        "
      >
        {{ item.description
        }}<span class="text-gray-600">{{ item.house_id }}</span>
      </div>
    </div>
  </div>
</template>

<script>
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  data() {
    return {
      selectedItem: {},
      inputValue: "",
      itemList: [],
      loaded: false,
      endPoint: "/api/house/list",
    };
  },
  props: {
    house_id: Number
  },
  mounted() {
    this.getList();
  },
  watch: {
    house_id: {
      immediate: true,
      handler() {
        document.house_id = this.house_id;
      },
    }
  },
  methods: {
    resetSelection() {
      this.selectedItem = {};
      this.$nextTick(() => this.$refs.dropdowninput.focus());
      this.$emit("onItemReset");
    },
    selectItem(theItem) {
      this.selectedItem = theItem;
      this.inputValue = "";
      this.$emit("onItemSelected", theItem);
    },
    itemVisible(item) {
      let currentDesc = item.description.toLowerCase();
      let currentId = item.house_id.toString();
      let currentInput = this.inputValue.toLowerCase();
      return (
        currentDesc.includes(currentInput) || currentId.includes(currentInput)
      );
    },
    validate() {
      if (this.$refs.dropdowninput) {
        if (!this.selectedItem.length || this.selectedItem.length <= 0) {
          this.$refs.dropdowninput.style.borderColor = "red";
          return false;
        }
      }
      return true;
    },
    getList() {
      // GET request to fetch data for the item list
      fetch(
        constants.server + this.endPoint,
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

          this.itemList = data.houses;
          if (this.house_id) {
            let selected = this.itemList.filter(item => item.house_id === this.house_id);
            if (selected.length > 0) {
              this.selectedItem = selected[0];
            }
          }
          this.loaded = true;
        })
        .catch((error) => {
          this.errorMessage = error;
          console.error(error);
        });
    },
  },
};
</script>