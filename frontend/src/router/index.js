import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'dashboard',
    component: () => import('@/views/Dashboard.vue'),
    children: [
      {
        path: '',
        component: () => import('@/views/dashboard/Home.vue'),
      },
      {
        path: '/users',
        name: 'users',
        component: () => import('@/views/users/UserList.vue'),
      },
      {
        path: '/reports/solar',
        name: 'solar',
        component: () => import('@/views/reports/Solar.vue'),
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
    component: () => import('@/views/Login.vue'),
  },
]

const router = createRouter({
  history: createWebHistory(),
  scrollBehavior() {
    return { top: 0 }
  },
  routes,
})

export default router
