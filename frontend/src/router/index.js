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
        meta: { auth: [constants.roles.Admin, constants.roles.Researcher] }
      },
      {
        path: '/devices/create',
        name: 'createdevice',
        component: () => import('@/views/devices/CreateDevice.vue'),
        meta: { auth: [constants.roles.Admin, constants.roles.Researcher] }
      },
      {
        path: '/devices/update/:id',
        name: 'updatedevice',
        component: () => import('@/views/devices/UpdateDevice.vue'),
        meta: { auth: [constants.roles.Admin, constants.roles.Researcher] }
      },
      {
        path: '/analytics',
        name: 'analytics',
        component: () => import('@/views/analytics/AnalyticsList.vue'),
        meta: { auth: [constants.roles.Admin, constants.roles.Researcher] }
      },
      {
        path: '/analytics/create',
        name: 'createanalytics',
        component: () => import('@/views/analytics/CreateAnalytics.vue'),
        meta: { auth: [constants.roles.Admin, constants.roles.Researcher] }
      },
      {
        path: '/analytics/update/:name',
        name: 'updateanalytics',
        component: () => import('@/views/analytics/UpdateAnalytics.vue'),
        meta: { auth: [constants.roles.Admin, constants.roles.Researcher] }
      },
      {
        path: '/users',
        name: 'users',
        component: () => import('@/views/users/UserList.vue'),
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/users/create',
        name: 'createuser',
        component: () => import('@/views/users/CreateUser.vue'),
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/users/update/',
        name: 'updateuser',
        component: () => import('@/views/users/UpdateUser.vue'),
        props: true,
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/roles',
        name: 'roles',
        component: () => import('@/views/roles/RoleList.vue'),
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/roles/create',
        name: 'createrole',
        component: () => import('@/views/roles/CreateRole.vue'),
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/houses',
        name: 'houses',
        component: () => import('@/views/houses/HouseList.vue'),
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/houses/create',
        name: 'createhouse',
        component: () => import('@/views/houses/CreateHouse.vue'),
        meta: { auth: [constants.roles.Admin] }
      },
      {
        path: '/houses/update/:id',
        name: 'updatehouse',
        component: () => import('@/views/houses/UpdateHouse.vue'),
        meta: { auth: [constants.roles.Admin] }
      }
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
  routes
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
