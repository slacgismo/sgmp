<template>
  <div class="loading-screen">
    <div class="loading-circle"></div>
    <p class="loading-text">Loading</p>
  </div>
</template>

<style scoped>
.loading-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-direction: column;
  user-select: none;
}
.loading-circle {
  width: 50px;
  height: 50px;
  border-radius: 100%;
  border: 2px solid transparent;
  border-left-color: grey;
  animation: circleanimation 0.45s linear infinite;
}
.loading-text {
  margin-top: 15px;
  color: grey;
  font-size: 12px;
  text-align: center;
}
@keyframes circleanimation {
  from {
    transform: rotateZ(0deg);
  }
  to {
    transform: rotateZ(360deg);
  }
}
</style>