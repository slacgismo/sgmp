
<template>
  <ul class="flex space-x-2">
    <li
      v-for="(tab, i) of tabs"
      :key="i"
      :class="
        active === i
          ? 'border-b-4 border-red-900 box-content text-red-900 font-bold'
          : 'border-b-4 hover:border-red-900'
      "
      class="
        flex
        items-center
        px-6
        py-2
        rounded-tl-md rounded-tr-md
        overflow-hidden
        cursor-pointer
      "
      @click="selectTab(i)"
    >
      {{ tab.props.title }}
    </li>
  </ul>
  <div class="bg-gray-100 -m-1 h-1"></div>
  <div class="mt-6">
    <slot />
  </div>
</template>

<script>
import { provide, computed, ref } from "vue";

export default {
  name: "Tabs",
  props: {
    modelValue: {
      type: [String, Number],
    },
  },
  emits: ["update:modelValue"],
  setup(props, { slots, emit }) {
    const active = computed(() => props.modelValue);
    const tabs = ref([]);

    function selectTab(tab) {
      emit("update:modelValue", tab);
    }

    provide("tabsState", {
      active,
      tabs,
    });

    return {
      tabs,
      active,
      selectTab,
    };
  },
};
</script>