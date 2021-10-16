import { createApp } from "vue"
import App from "./App.vue"
import "./assets/css/tailwind.css"
import router from "@/router"
import constants from "@/util/constants"

const app = createApp(App)
app.use(router)

// inject global methods
app.mixin({
    data() {
        return {
            houseId: 1,
        };
    },
    methods: {
        isAdmin() {
            if (localStorage && localStorage.roles &&
                localStorage.roles.includes(constants.roles.Admin)) {
                return true;
            }
            return false;
        }
    }
})

app.mount("#app")