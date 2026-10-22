defmodule AppWeb.HomeLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Courses

  @program_title "Resistência Antimicrobiana e Uso Racional de Antimicrobianos na Enfermagem"

  @impl true
  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(Map.get(session, "user_token"))

    {:ok,
     socket
     |> assign(current_user: user)
     |> assign(program_title: @program_title)
     |> assign(modules: Courses.list_modules_with_status(user))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container-xxl py-5">
      <.flash_group flash={@flash} id={"app-page-#{System.unique_integer([:positive]) |> Integer.to_string()}"} />

      <h1 class="display-3 fw-bold text-gray-900 mb-3">Módulos</h1>
      <h2 class="fs-2 fw-bold text-gray-700 mb-10"><%= @program_title %></h2>

      <%= if @modules == [] do %>
        <div class="alert alert-light-primary" id="modules-empty">
          Nenhum módulo disponível no momento.
        </div>
      <% end %>

      <div class="row g-6" id="modules">
        <%= for item <- @modules do %>
          <div class="col-12 col-sm-6 col-md-4 col-lg-3" id={"module-#{item.course.id}"}>
            <div class="card h-100 border border-gray-300 rounded-0 shadow-none">
              <div class="bg-light-secondary d-flex align-items-center justify-content-center overflow-hidden" style="height: 240px;">
                <%= if item.course.image && item.course.image != "" do %>
                  <img src={"/images/cursos/#{item.course.image}/banner.png"} alt={item.course.title} class="w-100 h-100" style="object-fit: cover;" />
                <% else %>
                  <i class="ki-outline ki-picture text-gray-500" style="font-size: 4rem;"></i>
                <% end %>
              </div>

              <div class="card-body d-flex flex-column p-6">
                <div class="d-flex align-items-center mb-3">
                  <h3 class="fs-1 fw-bolder text-gray-900 mb-0">Módulo <%= item.number %></h3>
                  <%= if item.completed? do %>
                    <span class="badge badge-light-success ms-3 fs-8">Concluído</span>
                  <% end %>
                </div>
                <div class="fw-bold text-gray-800 fs-4 mb-5"><%= item.course.title %></div>

                <div class="mt-auto">
                  <%= if item.requires do %>
                    <div class="fw-bold text-gray-700 fs-6 mb-3">Requisitos: Módulo <%= item.number - 1 %></div>
                  <% end %>
                  <div class="d-flex gap-3">
                    <.link
                      navigate={~p"/modulos/#{item.course.id}"}
                      id={"module-details-#{item.course.id}"}
                      class="btn btn-primary flex-fill px-3 py-3"
                    >
                      Mais Detalhes
                    </.link>
                    <%= if item.unlocked? do %>
                      <.link
                        navigate={App.CourseContent.start_path(item)}
                        id={"module-start-#{item.course.id}"}
                        class="btn btn-success flex-fill px-3 py-3"
                      >
                        <%= if item.completed?, do: "Revisar", else: "Iniciar" %>
                      </.link>
                    <% else %>
                      <button
                        type="button"
                        id={"module-start-#{item.course.id}"}
                        class="btn btn-secondary flex-fill px-3 py-3"
                        disabled
                      >
                        <i class="ki-outline ki-lock fs-6 me-1"></i>Iniciar
                      </button>
                    <% end %>
                  </div>
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
