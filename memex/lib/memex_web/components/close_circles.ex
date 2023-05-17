defmodule MemexWeb.CloseCircles do
  use Surface.Component

  def render(assigns) do
    ~F"""
    <section class="demo-container watch-container">
      <article class="watch">
        <div class="bg-image" />
        <div class="screen">
          <section class="dials">
            <div class="dial move">
              <div class="dial-background one" />
              <div class="dial-container container1">
                <div class="wedge" />
              </div>
              <div class="dial-container container2">
                <div class="wedge" />
              </div>
              <div class="marker start" />
              <div class="marker end" />
            </div>
            <div class="dial exercise">
              <div class="dial-background two" />
              <div class="dial-container container1">
                <div class="wedge" />
              </div>
              <div class="marker start" />
              <div class="marker end" />
            </div>
            <div class="dial stand">
              <div class="dial-background three" />
              <div class="dial-container container1">
                <div class="wedge" />
              </div>
              <div class="marker start" />
              <div class="marker end" />
            </div>
          </section>
        </div>
      </article>
    </section>
    """
  end
end
