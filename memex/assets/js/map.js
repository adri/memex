export const Map = {
  mounted() {
    const points = JSON.parse(this.el.dataset.points);
    console.log(points);
    var mapboxgl = require("mapbox-gl/dist/mapbox-gl.js");
    mapboxgl.accessToken =
      "pk.eyJ1IjoiYWRyaXAxMjMiLCJhIjoiY2tvN2Vpa3BlMGE4MTJ2cDd3Nmhrc25uMCJ9.SgEyt_86NvLxnETEfGjrcQ";
    this.map = new mapboxgl.Map({
      container: this.el.id,
      style: "mapbox://styles/mapbox/dark-v10",
      center: [points[0].lon, points[0].lat],
      zoom: 15,
    });

    this.map.on("load", () => {
      points.forEach((point) => {
        new mapboxgl.Marker().setLngLat([point.lon, point.lat]).addTo(this.map);
      });
    });
  },
  onMapClick(e) {
    console.log("You clicked the map at ", e.latlng),
      this.pushEvent("set-coords", e.latlng);
  },
  onPopupClick(e) {
    this.pushEvent("select-incident", e.latlng);
  },
};
