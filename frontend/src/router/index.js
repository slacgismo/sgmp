import { createRouter, createWebHistory } from 'vue-router'
import constants from "@/util/constants";

const routes = [
  {
    path: '/',
    name: 'dashboard',
    component: () => import('@/views/Dashboard.vue'),
    children: [
      {
        path: '',
        name: 'home',
        component: () => import('@/views/dashboard/Home.vue'),
        meta: { auth: [] }
      },
      {
        path: '/users',
        name: 'users',
        component: () => import('@/views/users/UserList.vue'),
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/reports/solar',
        name: 'solar',
        component: () => import('@/views/reports/Solar.vue'),
        meta: { auth: [] }
      },
      {
        path: '/reports/battery',
        name: 'battery',
        component: () => import('@/views/reports/Battery.vue'),
        meta: { auth: [] }
      },
      {
        path: '/reports/ev',
        name: 'ev',
        component: () => import('@/views/reports/EV.vue'),
        meta: { auth: [] }
      },
      {
        path: '/reports/load',
        name: 'load',
        component: () => import('@/views/reports/Load.vue'),
        meta: { auth: [] }
      },
      {
        path: '/devices',
        name: 'devices',
        component: () => import('@/views/devices/DeviceList.vue'),
        meta: { auth: [] }
      },
      // TODO
      // {
      //   path: '/outage',
      //   name: 'outage',
      //   component: () => import('@/views/Outage.vue'),
      // },
    ],
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/Login.vue')
  },
]

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior() {
    return { top: 0 }
  },
  routes,
})

router.beforeEach((to, from, next) => {
  // check authentication before route
  const { auth } = to.meta;
  if (auth) {
      if (!localStorage.username) {
          // redirect to the login page if unauthorized
          return next({ path: '/login', query: { redirect: to.path } });
      }

      // some pages are only accessible by certain role(s)
      if (auth.length && !auth.includes(localStorage.roles)) {
          // redirect to the home page if unauthorized
          return next({ path: '/' });
      }
  }

  next();
})

export default router
