export const ForceInputValue = {
  mounted() {
    this.handleEvent(
      "force-input-value",
      ({ value }) => (this.el.value = value)
    );

    // CMD + K to focus on the search input
    this.listener = document.addEventListener("keydown", (e) => {
      if (e.code !== "KeyK" || e.metaKey === false) return;

      this.el.focus();
      this.el.select();
    });
  },
};
