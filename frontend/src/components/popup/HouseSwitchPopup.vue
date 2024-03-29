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
    <div class="rounded-md bg-white p-8">
      <slot>
        <h1 class="text-2xl text-gray-800">Switch House</h1>
        
        <table class="w-full mt-2 text-gray-500" v-if="visible">
          <tbody class="divide-y divide-gray-200">
            <tr v-for="house in houseList" :key="house.house_id">
              <td class="p-2">
                <input type="radio" :value="house.house_id" v-model="selected" />
              </td>
              <td>{{ house.description }}</td>
            </tr>
          </tbody>
        </table>
        <loading v-else />

      </slot>
      <div class="flex space-x-4 mt-4">
        <slot>
          <button
            class="
              px-4
              py-2
              w-24
              text-sm text-white
              rounded-md
              bg-gray-400
              hover:bg-gray-300
            "
            @click="TogglePopup()"
          >
            Cancel
          </button>
          <button
            class="
              px-4
              py-2
              w-24
              text-sm text-white
              rounded-md
              bg-red-900
              hover:bg-red-700
            "
            @click="saveChange()"
          >
            Apply
          </button>
        </slot>
      </div>
    </div>
  </div>
</template>

<script>
import { ref } from 'vue';
import Loading from "@/components/Loading.vue";
import httpReq from "@/util/requestOptions";
import constants from "@/util/constants";

export default {
  components: { Loading },
  props: ["TogglePopup"],
  data() {
    return {
      visible: false,
      houseList: {}
    };
  },
  setup() {
    const selected = ref(false)
    return {
      selected
    }
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
        this.visible = true;
      })
      .catch((error) => {
        this.errorMessage = error;
        console.error(error);
      });
  },
  methods: {
    saveChange() {
      if (typeof(this.selected) != "number" ||
          this.selected == sessionStorage.getItem("house_id")) {
        this.TogglePopup();
        return;
      }

      let request = {
        "email": sessionStorage.getItem("email"),
        "name": sessionStorage.getItem("username"),
        "role": sessionStorage.getItem("roles"),
        "house_id": this.selected
      };
      // POST request to change the house selection
      fetch(
        constants.server + "/api/user/update", // endpoint
        httpReq.post(request) // requestOptions
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }

          sessionStorage.setItem("house_id", data.house_id);
          sessionStorage.setItem("house_desc", data.house_description);
          this.$router.go();  // reload page
        })
        .catch((error) => {
          this.errorMessage = error;
          console.error(error);
        });
      this.TogglePopup();
    }
  },
};
</script>