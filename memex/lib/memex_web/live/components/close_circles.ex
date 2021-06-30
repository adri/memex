defmodule MemexWeb.CloseCircles do
  use Surface.Component

  def render(assigns) do
    ~F"""
    <section class="demo-container watch-container">
        <article class="watch">
        <div class="bg-image"></div>
        <div class="screen">
            <section class="dials">
            <div class="dial move">
                <div class="dial-background one"></div>
                <div class="dial-container container1">
                <div class="wedge"></div>
                </div>
                <div class="dial-container container2">
                <div class="wedge"></div>
                </div>
                <div class="marker start"></div>
                <div class="marker end"></div>
            </div>
            <div class="dial exercise">
                <div class="dial-background two"></div>
                <div class="dial-container container1">
                <div class="wedge"></div>
                </div>
                <div class="marker start"></div>
                <div class="marker end"></div>
            </div>
            <div class="dial stand">
                <div class="dial-background three"></div>
                <div class="dial-container container1">
                <div class="wedge"></div>
                </div>
                <div class="marker start"></div>
                <div class="marker end"></div>
            </div>
            </section>
        </div>
        </article>
    </section>
    """
  end
end
