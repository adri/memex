export const Sidebar = {
  mounted() {
    this.toggleOnEscape();
  },
  updated() {
    if (this.el.dataset.open === "true") {
      this.lockScroll();
    } else {
      this.unlockScroll();
    }
  },
  toggleOnEscape() {
    this.listener = document.addEventListener("keyup", (e) => {
      if (e.code !== "Escape") return;

      this.pushEvent("close-last-sidebar");
    });
  },
  lockScroll() {
    document.body.style.overflow = `hidden`;
  },
  unlockScroll() {
    document.body.style.overflow = `auto`;
  },
};
