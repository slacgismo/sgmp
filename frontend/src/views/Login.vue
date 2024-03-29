<template>
  <div class="min-h-screen flex items-center justify-center px-4">
    <div class="max-w-md w-full">
      <!-- https://www6.slac.stanford.edu/about/logo-resources -->
      <img
        src="https://www6.slac.stanford.edu/sites/www6.slac.stanford.edu/files/SLAC-lab-hires.jpg"
        alt=""
      />
      <h2 class="py-8 text-center text-2xl font-bold text-gray-800 mb-6">
        Sign in to SGMP
      </h2>

      <!-- action="http://ec2-54-176-53-197.us-west-1.compute.amazonaws.com:5000/api/user/login" method="POST" -->
      <form class="space-y-4" @submit.prevent="validateSignIn">
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
                d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
              />
            </svg>
          </span>
          <input
            id="email"
            name="email"
            type="email"
            autocomplete="email"
            v-model="email"
            class="
              w-full
              py-4
              text-sm text-gray-900
              rounded-md
              pl-10
              border border-gray-300
              focus:outline-none
              focus:ring-blue-500
              focus:border-blue-500
              focus:z-10
            "
            placeholder="Email address"
            required=""
          />
        </div>

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
                d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"
              />
            </svg>
          </span>
          <input
            id="password"
            name="password"
            type="password"
            autocomplete="current-password"
            v-model="password"
            required=""
            class="
              w-full
              py-4
              text-sm text-gray-900
              rounded-md
              pl-10
              border border-gray-300
              focus:outline-none
              focus:ring-blue-500
              focus:border-blue-500
              focus:z-10
            "
            placeholder="Password"
          />
        </div>

        <div class="flex items-center justify-between">
          <div class="flex items-center">
            <input
              id="remember-me"
              name="remember-me"
              type="checkbox"
              class="
                h-4
                w-4
                text-blue-600
                focus:ring-0
                border-gray-300
                rounded
                cursor-pointer
              "
            />
            <label
              for="remember-me"
              class="ml-2 block text-sm text-gray-900 cursor-pointer"
            >
              Remember me
            </label>
          </div>

          <div class="text-sm">
            <a href="#" class="font-medium text-blue-600 hover:text-blue-500">
              Forgot your password?
            </a>
          </div>
        </div>

        <div>
          <button
            type="submit"
            class="
              group
              relative
              w-full
              flex
              justify-center
              py-2
              px-6
              border border-transparent
              font-medium
              rounded-md
              text-white
              bg-red-900
              hover:bg-red-800
              focus:outline-none
              focus:ring-2
              focus:ring-offset-2
              focus:ring-red-700
            "
          >
            Sign in
          </button>
        </div>
      </form>

      <div class="mt-2 text-sm text-gray-600">
        New to SGMP?
        <a href="#" class="font-medium text-blue-600 hover:text-blue-500"
          >Create an account</a
        >
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
      email: "",
      password: "",
    };
  },
  methods: {
    validateSignIn() {
      // POST request to validate the user's identification
      fetch(
        constants.server + "/api/user/login", // endpoint
        httpReq.post({
          // requestOptions
          email: this.email,
          password: this.password,
        })
      )
        .then(async (response) => {
          const data = await response.json();

          // check for error response
          if (!response.ok || !data.accesstoken) {
            // get error message from body or default to response status
            const error = (data && data.message) || response.status;
            return Promise.reject(error);
          }
          
          let signed = [];  // users that signed in already
          if (localStorage.getItem("users")) {
            signed = JSON.parse(localStorage.getItem("users"));
          }

          let profile = {};
          if (data.profile) {
            profile.token = data.accesstoken;
            sessionStorage.setItem("token", data.accesstoken);

            if (data.profile.name) {
              profile.username = data.profile.name;
            } else {
              profile.username = "User";
            }
            sessionStorage.setItem("username", profile.username);

            if (data.profile.email) {
              profile.email = data.profile.email;
              sessionStorage.setItem("email", profile.email);
            }
            if (data.profile.roles) {
              profile.roles = data.profile.roles;
              sessionStorage.setItem("roles", profile.roles);
            }
            if (data.house_id) {
              profile.house_id = parseInt(data.house_id);
              sessionStorage.setItem("house_id", profile.house_id);

              if (!data.house_description) {  // fallback: shouldn't happen
                data.house_description = "House";
              }
              profile.house_desc = data.house_description;
              sessionStorage.setItem("house_desc", profile.house_desc);
            }

            signed.push(profile);
            localStorage.setItem("users", JSON.stringify(signed));

            this.$router.push(this.$route.query.redirect || "/");
          }
        })
        .catch((error) => {
          this.errorMessage = error;
          alert("Sign in error: " + error);
        });
    },
  },
};
</script>
