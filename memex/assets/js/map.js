export const Map = {
  async mounted() {
    this.mapboxgl = await require("mapbox-gl");
    const response = await fetch(this.el.dataset.url, { method: "GET" });
    const geojson = await response.json();
    this.map = new this.mapboxgl.Map({
      container: this.el.id,
      accessToken:
        "pk.eyJ1IjoiYWRyaXAxMjMiLCJhIjoiY2tvN2Vpa3BlMGE4MTJ2cDd3Nmhrc25uMCJ9.SgEyt_86NvLxnETEfGjrcQ",
      style: "mapbox://styles/mapbox/dark-v10",
    });
    const map = this.map;

    map.fitBounds(this.getBounds(geojson), {
      padding: 30,
      maxZoom: 14.15,
      duration: 0,
    });

    map.on("load", () => {
      map.addSource("route", {
        type: "geojson",
        data: geojson,
      });

      map.addLayer({
        id: "route",
        type: "line",
        source: "route",
        layout: {
          "line-join": "round",
          "line-cap": "round",
        },
        paint: {
          "line-color": "#FCD34D",
          "line-width": 5,
        },
      });
    });
  },
  unmounted() {
    this.map.remove();
  },
  updated() {
    if (!this.map) return;
    const map = this.map;
    const items = JSON.parse(this.el.dataset.items);

    map.on("load", () => {
      for (let i = 0; i < items.length; i++) {
        const item = items[i];
        // if geometry: { type: "Point", create marker with properties config
        this.createMarker(item.data).addTo(map);
      }
    });
  },
  createMarker(feature) {
    const el = document.createElement("div");
    for (let prop of Object.keys(feature.properties.style)) {
      el.style[prop.toString()] = feature.properties.style[prop.toString()];
    }

    return new this.mapboxgl.Marker(el).setLngLat(feature.geometry.coordinates);
  },
  getBounds(geojson) {
    const first = geojson.geometry.coordinates[0];
    let bounds = new this.mapboxgl.LngLatBounds(first, first);

    geojson.geometry.coordinates.forEach((coordinate) => {
      bounds.extend(coordinate);
    });

    return bounds;
  },
};
