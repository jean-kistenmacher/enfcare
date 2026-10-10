defmodule AppWeb.ModalComponent do
  use AppWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @user.name %>, <%= @title %>
      </.header>

      <img
        src={~p"/images/doris_alegria.png"}
        style="position: absolute;right: 100px;height: 212px;"
        alt="Dóris"
        class="d-none d-lg-block"
      />

      <div class="mb-5">
        <!--begin::Heading-->
        <div class="d-flex flex-stack fw-semibold mb-4">
          <!--begin::Label-->
          <span class="text-muted fs-6 me-2">Vamos ver os desafios do dia?</span>
          <!--end::Label-->
        </div>
        <!--end::Heading-->
    										<!--begin::Items-->
        <div class="scroll-y mh-200px mh-lg-325px">
          <%= for objective <- @objectives do %>
            <!--begin::Item-->
            <div class="d-flex align-items-center mb-5">
              <!--begin::Symbol-->
              <div class="symbol symbol-40px me-4">
                <span class="symbol-label bg-light">
                  <i class={"ki-outline #{objective.icon} fs-2 text-primary"}></i>
                </span>
              </div>
              <!--end::Symbol-->
    												<!--begin::Title-->
              <div class="d-flex flex-column">
                <a href={objective.link} class="text-gray-800 fw-semibold">
                  <%= objective.description %>
                </a>
                <span class="fs-7 text-muted fw-semibold">(<%= objective.points %> pontos)</span>
              </div>
              <!--end::Title-->
            </div>
            <!--end::Item-->
          <% end %>
        </div>
        <!--end::Items-->
      </div>
    </div>
    """
  end
end
