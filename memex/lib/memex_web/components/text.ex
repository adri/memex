defmodule MemexWeb.Components.Text do
  @moduledoc false
  defmodule H1 do
    @moduledoc false
    use Surface.Component

    slot default

    def render(assigns) do
      ~F"""
      <div class="dark:text-white text-2xl font-bold"><#slot /></div>
      """
    end
  end

  defmodule H2 do
    @moduledoc false
    use Surface.Component

    slot default

    def render(assigns) do
      ~F"""
      <div class="text-white text-xl font-bold mt-5"><#slot /></div>
      """
    end
  end

  defmodule SubtTitle do
    @moduledoc false
    use Surface.Component

    slot default

    def render(assigns) do
      ~F"""
      <p class="dark:text-gray-400"><#slot /></p>
      """
    end
  end
end
