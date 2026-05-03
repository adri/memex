import {
  Chart,
  LineController,
  LineElement,
  BarController,
  BarElement,
  PointElement,
  LinearScale,
  CategoryScale,
  Filler,
  Tooltip,
} from "chart.js";

Chart.register(
  LineController,
  LineElement,
  BarController,
  BarElement,
  PointElement,
  LinearScale,
  CategoryScale,
  Filler,
  Tooltip
);

const accent = "#a78bfa";
const accentStrong = "#c4b5fd";
const previous = "rgba(148, 163, 184, 0.55)";
const previousSoft = "rgba(148, 163, 184, 0.12)";
const grid = "rgba(148, 163, 184, 0.08)";
const tick = "rgba(203, 213, 225, 0.7)";

function makeAreaGradient(ctx, area) {
  const gradient = ctx.createLinearGradient(0, area.top, 0, area.bottom);
  gradient.addColorStop(0, "rgba(167, 139, 250, 0.45)");
  gradient.addColorStop(0.55, "rgba(167, 139, 250, 0.12)");
  gradient.addColorStop(1, "rgba(167, 139, 250, 0)");
  return gradient;
}

function makeBarGradient(ctx, area) {
  const gradient = ctx.createLinearGradient(0, area.top, 0, area.bottom);
  gradient.addColorStop(0, "#c4b5fd");
  gradient.addColorStop(1, "#7c3aed");
  return gradient;
}

const baseOptions = {
  responsive: true,
  maintainAspectRatio: false,
  animation: { duration: 250 },
  layout: { padding: { top: 28, right: 12, bottom: 4, left: 4 } },
  plugins: {
    legend: { display: false },
    tooltip: {
      backgroundColor: "rgba(15, 23, 42, 0.95)",
      borderColor: "rgba(148, 163, 184, 0.25)",
      borderWidth: 1,
      padding: 10,
      titleColor: "#fff",
      bodyColor: "#cbd5f5",
    },
  },
  scales: {
    x: {
      grid: { display: false, drawBorder: false },
      border: { display: false },
      ticks: { color: tick, font: { size: 12 }, padding: 6 },
    },
    y: {
      beginAtZero: true,
      border: { display: false },
      grid: { color: grid, drawBorder: false },
      ticks: { color: tick, font: { size: 12 }, padding: 8 },
    },
  },
};

const valueLabelPlugin = {
  id: "valueLabels",
  afterDatasetsDraw(chart) {
    const { ctx } = chart;
    const ds = chart.data.datasets[0];
    if (!ds) return;
    const meta = chart.getDatasetMeta(0);
    ctx.save();
    ctx.font = "600 12px ui-sans-serif, system-ui, sans-serif";
    ctx.fillStyle = "#fff";
    ctx.textAlign = "center";
    ctx.textBaseline = "bottom";
    meta.data.forEach((point, i) => {
      const value = ds.data[i];
      if (value == null) return;
      ctx.fillText(String(value), point.x, point.y - 8);
    });
    ctx.restore();
  },
};

function buildDatasets(config) {
  const type = config.type === "bar" ? "bar" : "line";

  const current = {
    label: "Current",
    data: config.current ?? [],
    borderColor: accentStrong,
    backgroundColor: (ctx) => {
      const { chart } = ctx;
      const { ctx: c, chartArea } = chart;
      if (!chartArea) return "rgba(167, 139, 250, 0.18)";
      return type === "bar"
        ? makeBarGradient(c, chartArea)
        : makeAreaGradient(c, chartArea);
    },
    borderWidth: 2.5,
    tension: 0.4,
    fill: type === "line",
    pointBackgroundColor: accentStrong,
    pointBorderColor: "#0b0b12",
    pointBorderWidth: 2,
    pointRadius: type === "line" ? 4 : 0,
    pointHoverRadius: 6,
    borderRadius: type === "bar" ? 8 : 0,
    maxBarThickness: 36,
  };

  const datasets = [current];
  if (config.previous && config.previous.length) {
    datasets.push({
      label: "Previous",
      data: config.previous,
      borderColor: previous,
      backgroundColor: type === "bar" ? previous : previousSoft,
      borderWidth: 1.5,
      borderDash: type === "line" ? [4, 4] : [],
      tension: 0.4,
      fill: false,
      pointRadius: 0,
      pointHoverRadius: 4,
      borderRadius: type === "bar" ? 8 : 0,
      maxBarThickness: 36,
    });
  }
  return datasets;
}

function readConfig(el) {
  try {
    return JSON.parse(el.dataset.chartConfig || "{}");
  } catch {
    return {};
  }
}

export const ChartHook = {
  mounted() {
    this.render();
  },
  updated() {
    const config = readConfig(this.el);
    if (!this.chart || this.chart.config.type !== (config.type || "line")) {
      this.render();
      return;
    }
    this.chart.data.labels = config.labels ?? [];
    this.chart.data.datasets = buildDatasets(config);
    this.chart.update();
  },
  destroyed() {
    if (this.chart) this.chart.destroy();
  },
  render() {
    if (this.chart) {
      this.chart.destroy();
      this.chart = null;
    }
    const config = readConfig(this.el);
    const type = config.type === "bar" ? "bar" : "line";
    const canvas = this.el.querySelector("canvas");
    if (!canvas) return;

    this.chart = new Chart(canvas, {
      type,
      data: {
        labels: config.labels ?? [],
        datasets: buildDatasets(config),
      },
      options: baseOptions,
      plugins: type === "line" ? [valueLabelPlugin] : [],
    });
  },
};
