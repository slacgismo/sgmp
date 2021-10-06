<template>
  <div class="flex items-center bg-white border rounded-sm overflow-hidden shadow">
    <div class="p-2">
      <!-- https://www.svgrepo.com/svg/203990/trophy-champion -->
      <img :src="getImage()" class="h-24 w-24" />
    </div>
    
    <div class="text-gray-700 px-4">
      <h3 class="text-sm tracking-wider">{{ title }}</h3>
      <div class="flex items-center gap-4">
        <p class="text-3xl sm:text-2xl">{{ value }}</p>
        <!-- https://www.svgrepo.com/svg/305138/arrowhead-left -->
        <img src="/src/assets/img/arrow.svg" class="h-12 w-12" />
        <!-- <span class="text-8xl font-thin text-gray-300 italic">/</span> -->
        <p class="text-xl text-right tracking-wider pr-4">{{ time }}</p>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: "AnalyticCard",
  props: {
    title: String,
    img: String,
    value: String,
    time: String
  },
  watch: {
    title: {
      immediate: true,
      handler() {
        document.title = this.title;
      }
    },
    value: {
      immediate: true,
      handler() {
        document.value = this.value;
      }
    },
    time: {
      immediate: true,
      handler() {
        document.time = this.time;
      }
    }
  },
  methods: {
    getImage () {
      return "/src/assets/img/" + this.img;
    }
  }
};
</script>