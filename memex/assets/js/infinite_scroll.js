export const InfiniteScroll = {
  page() {
    return this.el.dataset.page;
  },
  loadMore(entries) {
    const target = entries[0];

    if (target.isIntersecting && this.pending == this.page()) {
      this.pending = this.page() + 1;
      this.pushEvent("load-more", {});
    }
  },
  mounted() {
    this.pending = this.page();
    this.observer = new IntersectionObserver(
      (entries) => this.loadMore(entries),
      {
        root: null, // window by default
        rootMargin: "0px",
        threshold: 1.0,
      }
    );
    this.observer.observe(this.el);
  },
  beforeDestroy() {
    this.observer.unobserve(this.el);
  },
  updated() {
    if (this.el.dataset.query && this.el.dataset.query != this.query) {
      document.body.scrollTo(0, 0);
    }

    this.query = this.el.dataset.query;
    this.pending = this.page();
  },
};
