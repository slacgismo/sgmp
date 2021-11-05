import { createApp } from "vue"
import App from "./App.vue"
import "./assets/css/tailwind.css"
import router from "@/router"
import constants from "@/util/constants"

const app = createApp(App)
app.use(router)

app.mount("#app")