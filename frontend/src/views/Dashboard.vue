<template>
  <div class="flex min-h-screen">
    <my-sidebar />

    <div class="flex flex-col flex-grow">
      <my-header />

      <div class="mb-auto">
        <router-view />
      </div>

      <my-footer />
    </div>
  </div>
</template>

<script>
import MySidebar from '@/components/layouts/MySidebar.vue'
import MyHeader from '@/components/layouts/MyHeader.vue'
import MyFooter from '@/components/layouts/MyFooter.vue'

export default {
  components: {
    MySidebar,
    MyHeader,
    MyFooter,
  },
}
</script>
