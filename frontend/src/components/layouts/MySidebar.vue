<template>
  <aside class="hidden w-52 bg-gray-200 sm:block">
    <div
      class="
        py-4
        text-2xl
        uppercase
        text-center
        tracking-widest
        bg-red-900
        border-b-2 border-gray-800
        mb-4
      "
    >
      <router-link to="/">
        <!-- https://www6.slac.stanford.edu/about/logo-resources -->
        <img
          class="px-2"
          src="https://www6.slac.stanford.edu/sites/www6.slac.stanford.edu/files/SLAC_LogoSD_W.png"
          alt=""
        />
      </router-link>
    </div>

    <nav class="text-sm">
      <ul class="flex flex-col">
        <li class="px-4 py-2 text-xs uppercase tracking-wider font-bold">
          Analytics
        </li>

        <router-link v-slot="{ isExactActive, href, navigate }" to="/">
          <li
            class="px-4 cursor-pointer"
            :class="[
              isExactActive ? 'bg-white text-red-900' : 'hover:bg-gray-100',
            ]"
          >
            <a class="py-3 flex items-center" :href="href" @click="navigate">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 mr-2"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <!-- http://svgicons.sparkk.fr/ -->
                <path
                  d="M17.237,3.056H2.93c-0.694,0-1.263,0.568-1.263,1.263v8.837c0,0.694,0.568,1.263,1.263,1.263h4.629v0.879c-0.015,0.086-0.183,0.306-0.273,0.423c-0.223,0.293-0.455,0.592-0.293,0.92c0.07,0.139,0.226,0.303,0.577,0.303h4.819c0.208,0,0.696,0,0.862-0.379c0.162-0.37-0.124-0.682-0.374-0.955c-0.089-0.097-0.231-0.252-0.268-0.328v-0.862h4.629c0.694,0,1.263-0.568,1.263-1.263V4.319C18.5,3.625,17.932,3.056,17.237,3.056 M8.053,16.102C8.232,15.862,8.4,15.597,8.4,15.309v-0.89h3.366v0.89c0,0.303,0.211,0.562,0.419,0.793H8.053z M17.658,13.156c0,0.228-0.193,0.421-0.421,0.421H2.93c-0.228,0-0.421-0.193-0.421-0.421v-1.263h15.149V13.156z M17.658,11.052H2.509V4.319c0-0.228,0.193-0.421,0.421-0.421h14.308c0.228,0,0.421,0.193,0.421,0.421V11.052z"
                />
              </svg>
              Dashboard
            </a>
          </li>
        </router-link>

        <li>
          <Disclosure v-slot="{ open }" :default-open="true">
            <DisclosureButton
              class="px-4 py-3 flex items-center w-52 hover:bg-gray-100"
              :class="open ? 'bg-gray-100' : ''"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 mr-2"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  d="M10.281,1.781C5.75,1.781,2.062,5.469,2.062,10s3.688,8.219,8.219,8.219S18.5,14.531,18.5,10S14.812,1.781,10.281,1.781M10.714,2.659c3.712,0.216,6.691,3.197,6.907,6.908h-6.907V2.659z M10.281,17.354c-4.055,0-7.354-3.298-7.354-7.354c0-3.911,3.067-7.116,6.921-7.341V10c0,0.115,0.045,0.225,0.127,0.305l5.186,5.189C13.863,16.648,12.154,17.354,10.281,17.354M15.775,14.882l-4.449-4.449h6.295C17.522,12.135,16.842,13.684,15.775,14.882"
                />
              </svg>
              Reports
              <span class="ml-auto">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  :class="open ? 'transform rotate-90' : ''"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </span>
            </DisclosureButton>
            <DisclosurePanel>
              <ul>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  :to="{ name: 'solar' }"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive
                        ? 'bg-white text-red-900'
                        : 'hover:bg-gray-100',
                    ]"
                  >
                    <a
                      class="py-3 flex items-center"
                      :href="href"
                      @click="navigate"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Solar
                    </a>
                  </li>
                </router-link>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  :to="{ name: 'battery' }"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive
                        ? 'bg-white text-red-900'
                        : 'hover:bg-gray-100',
                    ]"
                  >
                    <a
                      class="py-3 flex items-center"
                      :href="href"
                      @click="navigate"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Battery
                    </a>
                  </li>
                </router-link>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  :to="{ name: 'ev' }"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive
                        ? 'bg-white text-red-900'
                        : 'hover:bg-gray-100',
                    ]"
                  >
                    <a
                      class="py-3 flex items-center"
                      :href="href"
                      @click="navigate"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Electric Vehicle
                    </a>
                  </li>
                </router-link>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  :to="{ name: 'load' }"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive
                        ? 'bg-white text-red-900'
                        : 'hover:bg-gray-100',
                    ]"
                  >
                    <a
                      class="py-3 flex items-center"
                      :href="href"
                      @click="navigate"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Loads
                    </a>
                  </li>
                </router-link>
              </ul>
            </DisclosurePanel>
          </Disclosure>
        </li>

        <li
          v-show="isAdmin()"
          class="px-4 py-2 mt-2 text-xs uppercase tracking-wider font-bold"
        >
          Administration
        </li>

        <li v-show="isAdmin()">
          <Disclosure v-slot="{ open }" :default-open="isActive(configRoutes)">
            <DisclosureButton
              class="px-4 py-3 flex items-center w-52 hover:bg-gray-100"
              :class="open ? 'bg-gray-100' : ''"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 mr-2"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <!-- https://icomoon.io/ -->
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M23.506 19.169l-10.794-9.252c0.503-0.944 0.788-2.022 0.788-3.167 0-3.728-3.022-6.75-6.75-6.75-0.682 0-1.34 0.102-1.96 0.29l3.9 3.9c0.583 0.583 0.583 1.538 0 2.121l-2.379 2.379c-0.583 0.583-1.538 0.583-2.121 0l-3.9-3.9c-0.188 0.62-0.29 1.279-0.29 1.96 0 3.728 3.022 6.75 6.75 6.75 1.145 0 2.222-0.285 3.167-0.788l9.252 10.794c0.537 0.626 1.454 0.662 2.037 0.078l2.379-2.379c0.583-0.583 0.548-1.5-0.078-2.037z"
                />
              </svg>
              Configuration
              <span class="ml-auto">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  :class="open ? 'transform rotate-90' : ''"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </span>
            </DisclosureButton>
            <DisclosurePanel>
              <ul>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  to="/devices"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive ? 'bg-white text-red-900' : 'hover:bg-gray-100',
                    ]"
                  >
                    <a class="py-3 flex items-center" :href="href" @click="navigate">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Device
                    </a>
                  </li>
                </router-link>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  to="/analytics"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive ? 'bg-white text-red-900' : 'hover:bg-gray-100',
                    ]"
                  >
                    <a class="py-3 flex items-center" :href="href" @click="navigate">
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Analytic Items
                    </a>
                  </li>
                </router-link>
              </ul>
            </DisclosurePanel>
          </Disclosure>
        </li>

        <li v-show="isAdmin()">
          <Disclosure v-slot="{ open }" :default-open="isActive(userRoutes)">
            <DisclosureButton
              class="px-4 py-3 flex items-center w-52 hover:bg-gray-100"
              :class="open ? 'bg-gray-100' : ''"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 mr-2"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                />
              </svg>
              User Management
              <span class="ml-auto">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-5 w-5"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                  :class="open ? 'transform rotate-90' : ''"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    stroke-width="2"
                    d="M9 5l7 7-7 7"
                  />
                </svg>
              </span>
            </DisclosureButton>
            <DisclosurePanel>
              <ul>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  :to="{ name: 'users' }"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive
                        ? 'bg-white text-red-900'
                        : 'hover:bg-gray-100',
                    ]"
                  >
                    <a
                      class="py-3 flex items-center"
                      :href="href"
                      @click="navigate"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Users
                    </a>
                  </li>
                </router-link>
                <router-link
                  v-slot="{ isExactActive, href, navigate }"
                  :to="{ name: 'roles' }"
                >
                  <li
                    class="pl-8"
                    :class="[
                      isExactActive
                        ? 'bg-white text-red-900'
                        : 'hover:bg-gray-100',
                    ]"
                  >
                    <a
                      class="py-3 flex items-center"
                      :href="href"
                      @click="navigate"
                    >
                      <svg
                        xmlns="http://www.w3.org/2000/svg"
                        class="h-5 w-5"
                        fill="currentColor"
                        viewBox="0 0 16 16"
                      >
                        <path d="M8 9.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z" />
                      </svg>
                      Roles
                    </a>
                  </li>
                </router-link>
              </ul>
            </DisclosurePanel>
          </Disclosure>
        </li>
      </ul>
    </nav>
  </aside>
</template>

<script>
import { computed } from "vue";
import { useRoute } from "vue-router";
import { Disclosure, DisclosureButton, DisclosurePanel } from "@headlessui/vue";

import constants from "@/util/constants";
import httpReq from "@/util/requestOptions";

export default {
  components: {
    Disclosure,
    DisclosureButton,
    DisclosurePanel,
  },
  setup() {
    const route = useRoute();
    return {
      route
    };
  },
  data() {
    return {
      userRoutes: ["users", "createuser", "updateuser", "roles", "createrole"],
      configRoutes: ["devices", "createdevice", "updatedevice", "analytics", "createanalytics", "updateanalytics"]
    };
  },
  created() {
    // POST request to fetch data for the houses
    fetch(
      constants.server + "/api/device/list", // endpoint
      httpReq.post({ house_id: localStorage.getItem("house_id") }) // requestOptions
    )
      .then(async (response) => {
        const data = await response.json();

        // check for error response
        if (!response.ok) {
          // get error message from body or default to response status
          const error = (data && data.message) || response.status;
          return Promise.reject(error);
        }
      })
      .catch((error) => {
        this.errorMessage = error;
        console.error(error);
      });
  },
  methods: {
    isActive(routes) {
      return routes.includes(this.route.name);
    }
  }
};
</script>