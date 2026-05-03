defmodule MemexWeb.Chart do
  @moduledoc false
  use Surface.Component

  alias Phoenix.LiveView.JS

  @target "#search-input"

  prop(data, :map, required: true)

  def render(assigns) do
    ~F"""
    <div class="relative overflow-hidden rounded-2xl border border-white/10 p-6 shadow-2xl">
      <div class="absolute inset-0 -z-10 bg-[radial-gradient(circle_at_top_left,rgba(124,58,237,0.18),transparent_55%),radial-gradient(circle_at_bottom_right,rgba(56,189,248,0.08),transparent_60%),linear-gradient(180deg,#11101a_0%,#08070d_100%)]" />

      <div class="flex items-start justify-between">
        <div class="flex items-center gap-3">
          <h2 class="text-lg font-semibold tracking-tight text-white">{@data.title}</h2>
          <span class="rounded-md border border-white/10 bg-white/5 px-2 py-0.5 text-xs font-medium text-gray-300">{@data.range_label}</span>
        </div>
        <div class="flex items-center gap-1 rounded-lg border border-white/10 bg-white/5 p-1">
          <button
            type="button"
            class={type_button_class(@data.type, "line")}
            phx-click={set_type("line")}
            title="Line"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <path d="M3 17l6-6 4 4 8-8" />
            </svg>
          </button>
          <button
            type="button"
            class={type_button_class(@data.type, "bar")}
            phx-click={set_type("bar")}
            title="Bar"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="4" y="10" width="3" height="10" />
              <rect x="10.5" y="6" width="3" height="14" />
              <rect x="17" y="13" width="3" height="7" />
            </svg>
          </button>
          <button
            type="button"
            class={type_button_class(@data.type, "table")}
            phx-click={set_type("table")}
            title="Table"
          >
            <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <rect x="3" y="4" width="18" height="16" rx="2" />
              <path d="M3 10h18M9 4v16" />
            </svg>
          </button>
        </div>
      </div>

      <div :if={@data.type !== "table"} class="mt-5">
        <div
          id="chart-canvas"
          phx-hook="ChartHook"
          phx-update="ignore"
          data-chart-config={Jason.encode!(@data)}
          class="relative h-[300px] w-full"
        >
          <canvas></canvas>
        </div>
      </div>

      <div :if={@data.type === "table"} class="mt-5 overflow-hidden rounded-xl border border-white/10">
        <table class="w-full text-sm text-gray-200">
          <thead class="bg-white/5 text-xs uppercase tracking-wide text-gray-400">
            <tr>
              <th class="px-4 py-2.5 text-left font-medium">Bucket</th>
              <th class="px-4 py-2.5 text-right font-medium">Current</th>
              <th class="px-4 py-2.5 text-right font-medium">Previous</th>
            </tr>
          </thead>
          <tbody>
            <tr :for.with_index={{label, i} <- @data.labels} class="border-t border-white/5 hover:bg-white/[0.03]">
              <td class="px-4 py-2 text-gray-300">{label}</td>
              <td class="px-4 py-2 text-right font-medium text-white">{Enum.at(@data.current, i)}</td>
              <td class="px-4 py-2 text-right text-gray-500">{Enum.at(@data.previous, i)}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="mt-5 flex items-center justify-between border-t border-white/5 pt-4 text-sm">
        <div class="flex items-baseline gap-3">
          <span class="text-white">
            <span class="text-base font-semibold">{@data.current_total}</span>
            <span class="ml-1 text-gray-400">{@data.unit_label}</span>
          </span>
          <span :if={@data.delta_pct != nil} class="flex items-baseline gap-1.5 text-xs">
            <span class={delta_class(@data.delta_pct)}>
              {delta_arrow(@data.delta_pct)} {abs(@data.delta_pct)}%
            </span>
            <span class="text-gray-500">vs {@data.previous_range_label} ({@data.previous_total})</span>
          </span>
        </div>
        <div class="text-xs text-gray-400">
          Daily average: <span class="font-medium text-gray-200">{@data.daily_average}</span>
        </div>
      </div>
    </div>
    """
  end

  defp set_type(type) do
    %JS{}
    |> JS.dispatch("removeFilter", to: @target, detail: %{key: "chart"})
    |> JS.dispatch("addFilter", to: @target, detail: %{key: "chart", value: type})
    |> JS.dispatch("search", to: @target)
  end

  defp type_button_class(active, type) do
    base = "flex items-center justify-center rounded-md px-2 py-1.5 transition-colors"

    if active == type do
      base <> " bg-indigo-500/20 text-indigo-200 ring-1 ring-indigo-400/40"
    else
      base <> " text-gray-400 hover:text-gray-100 hover:bg-white/5"
    end
  end

  defp delta_class(pct) when pct >= 0, do: "font-medium text-green-400"
  defp delta_class(_), do: "font-medium text-red-400"

  defp delta_arrow(pct) when pct >= 0, do: "↑"
  defp delta_arrow(_), do: "↓"
end
