defmodule AppWeb.ShowLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Courses
  import App.Utils

  @impl true
  def mount(params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = Accounts.get_user_by_session_token(user_token)
    id = Map.get(params, "id")

    info_page = %{
      title: "Home",
      breadcrumb: []
    }

    try do
      type =
        if user.superadmin do
          "managers"
        else
          user.type
        end
      course =
        if type == "managers" do
          Courses.get_course!(String.to_integer(id))
        else
          Courses.get_course_by_type!(String.to_integer(id), type)
        end
      last_courses =
        if type == "managers" do
          Courses.get_courses(5, "desc")
        else
          Courses.get_courses_by_type(5, "desc", type)
        end
      list_3_courses =
        if type == "managers" do
          Courses.get_random_courses(3)
        else
          Courses.get_random_courses_by_type(3, type)
        end

      # Filtrar o curso atual e os módulos ainda bloqueados da lista de cursos sugeridos
      modules = Courses.list_modules_with_status(user)
      unlocked_ids = for %{unlocked?: true, course: c} <- modules, into: MapSet.new(), do: c.id
      module_completed = Enum.any?(modules, &(&1.course.id == course.id and &1.completed?))

      list_3_courses =
        Enum.filter(list_3_courses, fn c -> c.id != course.id and MapSet.member?(unlocked_ids, c.id) end)

      if MapSet.member?(unlocked_ids, course.id) do
        {:ok,
         assign(socket, current_user: user)
         |> assign(info_page: info_page)
         |> assign(course: course)
         |> assign(last_courses: last_courses)
         |> assign(list_3_courses: list_3_courses)
         |> assign(module_completed: module_completed)
         |> assign(form1_clicked: false)
         |> assign(session_restored: false)}
      else
        {:ok,
         socket
         |> put_flash(:error, "Conclua o módulo anterior para acessar este conteúdo.")
         |> redirect(to: "/")}
      end
    rescue
      _ -> {:error, redirect(socket, to: "/")}
    end
  end

  @impl true
  def handle_event("form1_clicked", _params, socket) do
    {:noreply,
     socket
     |> assign(form1_clicked: true)
     |> push_event("mark_completed", %{})}
  end

  @impl true
  def handle_event("restore_session", %{"completed" => true}, socket) do
    {:noreply,
     socket
     |> assign(form1_clicked: true)
     |> assign(session_restored: true)}
  end

  @impl true
  def handle_event("complete_module", _params, socket) do
    %{current_user: user, course: course, form1_clicked: form1_clicked} = socket.assigns

    with true <- can_complete?(course, form1_clicked),
         {:ok, _completion} <- Courses.complete_course(user, course) do
      {:noreply,
       socket
       |> put_flash(:info, "Módulo concluído! O próximo módulo foi liberado.")
       |> redirect(to: "/")}
    else
      _ -> {:noreply, put_flash(socket, :error, "Finalize o conteúdo do módulo antes de concluí-lo.")}
    end
  end

  # Sem formulário 1 cadastrado, não há etapa a cumprir antes de concluir.
  defp can_complete?(course, form1_clicked) do
    form1_clicked or course.form1 in [nil, ""]
  end

  @impl true
  def render(assigns) do
    ~H"""
        <!--begin::Post-->
    <div class="post d-flex flex-column-fluid" id="kt_post" phx-hook="ProtocolSession" data-course-id={@course.id}>
      <!--begin::Container-->
      <div id="kt_content_container" class="container-xxl">
        <!--begin::Post card-->
        <div class="card">
          <!--begin::Body-->
          <div class="card-body p-lg-20">
            <!--begin::Layout-->
            <div class="d-flex flex-column">
              <!--begin::Content-->
              <div class="flex-lg-row-fluid">
                <!--begin::Post content-->
                <div class="mb-10">

                  <!--begin::Title-->
                  <h1 class="text-gray-900 fw-bolder mb-6"><%= @course.title %></h1>
                  <!--end::Title-->

                  <!--begin::Info-->
                  <div class="d-flex flex-wrap mb-8">
                    <div class="me-9 my-1">
                      <i class="ki-outline ki-element-11 text-primary fs-2 me-1"></i>
                      <span class="fw-bold text-gray-500">
                        <%= format_datetime_crud(@course.date) %>
                      </span>
                    </div>
                  </div>
                  <!--end::Info-->

                  <!--begin::Description-->
                  <div class="fs-5 fw-semibold text-gray-700 mb-10">
                    <%= @course.description %>
                  </div>
                  <!--end::Description-->

                  <!--begin::Image-->
                  <div class="mb-10 text-center">
                    <a class="d-inline-block overlay position-relative" data-fslightbox="lightbox-course-image" href={@course.image} style="max-width: 600px; width: 100%;">
                      <img src={@course.image} alt={@course.title} class="img-fluid card-rounded" style="width: 100%; height: auto;" />
                      <div class="overlay-layer card-rounded bg-dark bg-opacity-25 d-flex align-items-center justify-content-center">
                        <i class="ki-outline ki-eye fs-2x text-white"></i>
                      </div>
                    </a>
                    <div class="text-muted mt-2 fs-7">
                      <i class="ki-outline ki-mouse fs-6 me-1"></i>
                      Clique na imagem para ampliar
                    </div>
                  </div>
                  <!--end::Image-->

                  <!--begin::Session Restored Notice-->
                  <%= if @session_restored do %>
                    <div class="alert alert-dismissible bg-light-success d-flex flex-column flex-sm-row p-5 mb-8">
                      <i class="ki-outline ki-shield-tick fs-2hx text-success me-4 mb-5 mb-sm-0"></i>
                      <div class="d-flex flex-column pe-0 pe-sm-10">
                        <h4 class="fw-semibold">Protocolo já Completado</h4>
                        <span>Você já preencheu o formulário inicial deste protocolo nesta sessão. Todo o conteúdo está disponível abaixo.</span>
                      </div>
                      <button type="button" class="position-absolute position-sm-relative m-2 m-sm-0 top-0 end-0 btn btn-icon ms-sm-auto" data-bs-dismiss="alert">
                        <i class="ki-outline ki-cross fs-1 text-success"></i>
                      </button>
                    </div>
                  <% end %>
                  <!--end::Session Restored Notice-->

                  <!--begin::Form 1 Link-->
                  <%= if @course.form1 && @course.form1 != "" do %>
                    <div class={"card mb-8 #{if @form1_clicked, do: "bg-light-success", else: "bg-light-primary"}"}>
                      <div class="card-body p-6">
                        <h3 class="card-title text-gray-900 fw-bold mb-3">
                          <i class={"ki-outline ki-document fs-2 me-2 #{if @form1_clicked, do: "text-success", else: "text-primary"}"}>
                          </i>
                          Formulário 1
                          <%= if @form1_clicked do %>
                            <span class="badge badge-success ms-2">Concluído</span>
                          <% end %>
                        </h3>
                        <p class="text-gray-700 mb-4">
                          <%= if @form1_clicked do %>
                            Formulário já preenchido. Você pode acessá-lo novamente se necessário.
                          <% else %>
                            Preencha o primeiro formulário antes de assistir ao vídeo.
                          <% end %>
                        </p>
                        <a href={@course.form1} target="_blank" class={"btn #{if @form1_clicked, do: "btn-success", else: "btn-primary"}"} phx-click="form1_clicked">
                          <i class="ki-outline ki-external-link fs-3 me-1"></i>
                          <%= if @form1_clicked, do: "Acessar Novamente", else: "Abrir Formulário 1" %>
                        </a>
                      </div>
                    </div>
                  <% end %>
                  <!--end::Form 1 Link-->

                  <!--begin::Video-->
                  <%= if @form1_clicked && @course.video && @course.video != "" do %>
                    <div class="mb-8">
                      <h3 class="text-gray-900 fw-bold mb-5">Vídeo do Curso</h3>
                      <div class="ratio ratio-16x9 card-rounded overflow-hidden">
                        <iframe
                          src={"https://www.youtube.com/embed/#{@course.video}"}
                          title="YouTube video"
                          allowfullscreen
                          class="card-rounded"
                        ></iframe>
                      </div>
                    </div>
                  <% end %>
                  <!--end::Video-->

                   <!--begin::PDF Download-->
                  <%= if @form1_clicked && @course.pdf && @course.pdf != "" do %>
                    <div class="card bg-light-info mb-8">
                      <div class="card-body p-6">
                        <h3 class="card-title text-gray-900 fw-bold mb-3">
                          <i class="ki-outline ki-file-down text-info fs-2 me-2"></i>
                          Material em PDF
                        </h3>
                        <p class="text-gray-700 mb-4">Baixe o material complementar em PDF.</p>
                        <a href={@course.pdf} download="material-curso.pdf" class="btn btn-info">
                          <i class="ki-outline ki-download fs-3 me-1"></i>
                          Baixar PDF
                        </a>
                      </div>
                    </div>
                  <% end %>
                  <!--end::PDF Download-->

                  <!--begin::Form 2 Link-->
                  <%= if @form1_clicked && @course.form2 && @course.form2 != "" do %>
                    <div class="card bg-light-success mb-8">
                      <div class="card-body p-6">
                        <h3 class="card-title text-gray-900 fw-bold mb-3">
                          <i class="ki-outline ki-document text-success fs-2 me-2"></i>
                          Formulário 2
                        </h3>
                        <p class="text-gray-700 mb-4">Após assistir ao vídeo, preencha o segundo formulário.</p>
                        <a href={@course.form2} target="_blank" class="btn btn-success">
                          <i class="ki-outline ki-external-link fs-3 me-1"></i>
                          Abrir Formulário 2
                        </a>
                      </div>
                    </div>
                  <% end %>
                  <!--end::Form 2 Link-->

                  <!--begin::Text Content-->
                  <%= if @course.text && @course.text != "" do %>
                    <div class="fs-5 fw-normal text-gray-700 mb-10">
                      <h3 class="text-gray-900 fw-bold mb-5">Conteúdo Adicional</h3>
                      <%= raw(@course.text) %>
                    </div>
                  <% end %>
                  <!--end::Text Content-->

                  <!--begin::Complete module-->
                  <%= if can_complete?(@course, @form1_clicked) do %>
                    <div class="card bg-light-primary mb-8" id="complete-module">
                      <div class="card-body p-6">
                        <h3 class="card-title text-gray-900 fw-bold mb-3">
                          <i class="ki-outline ki-check-circle text-primary fs-2 me-2"></i>
                          Concluir módulo
                        </h3>
                        <%= if @module_completed do %>
                          <p class="text-gray-700 mb-0">Você já concluiu este módulo.</p>
                        <% else %>
                          <p class="text-gray-700 mb-4">Ao finalizar o conteúdo, conclua o módulo para liberar o próximo.</p>
                          <button type="button" id="complete-module-btn" class="btn btn-primary" phx-click="complete_module">
                            Concluir módulo
                          </button>
                        <% end %>
                      </div>
                    </div>
                  <% end %>
                  <!--end::Complete module-->

                </div>
                <!--end::Post content-->
              </div>
              <!--end::Content-->
            </div>
            <!--end::Layout-->
    					<!--begin::Section-->
            <%= if length(@list_3_courses) > 0 do %>
              <div class="mb-17">
                <!--begin::Content-->
                <div class="d-flex flex-stack mb-5">
                  <!--begin::Title-->
                  <h3 class="text-gray-900">Vamos aprender mais?</h3>
                  <!--end::Title-->
                </div>
                <!--end::Content-->
      						<!--begin::Separator-->
                <div class="separator separator-dashed mb-9"></div>
                <!--end::Separator-->
      						<!--begin::Row-->
                <div class="row g-10">
                  <%= for course <- @list_3_courses do %>
                  <!--begin::Col-->
                  <div class="col-md-4">
                    <!--begin::Feature post-->
                    <div class="card-xl-stretch me-md-6">
                      <%= if course.video do %>
                        <!--begin::Image-->
                        <a
                          class="d-block bgi-no-repeat bgi-size-cover bgi-position-center card-rounded position-relative min-h-175px mb-5"
                          style={"background-image:url('#{course.image}')"}
                          data-fslightbox="lightbox-video-tutorials"
                          href={"https://www.youtube.com/embed/#{course.video}"}
                        >
                          <img
                            src="/images/media/svg/misc/video-play.svg"
                            class="position-absolute top-50 start-50 translate-middle"
                            alt=""
                          />
                        </a>
                        <!--end::Image-->
                      <% else %>
                        <a
                          class="d-block overlay"
                          data-fslightbox="lightbox-hot-sales"
                          href={"#{course.image}"}
                        >
                          <!--begin::Image-->
                          <div
                            class="overlay-wrapper bgi-no-repeat bgi-position-center bgi-size-cover card-rounded min-h-175px"
                            style={"background-image:url('#{course.image}')"}
                          >
                          </div>
                          <!--end::Image-->
    							<!--begin::Action-->
                          <div class="overlay-layer card-rounded bg-dark bg-opacity-25">
                            <i class="ki-outline ki-eye fs-2x text-white"></i>
                          </div>
                          <!--end::Action-->
                        </a>
                      <% end %>
                      <!--begin::Body-->
                      <div class="m-0">
                        <!--begin::Title-->
                        <a
                          href={"/show/#{course.id}"}
                          class="fs-4 text-gray-900 fw-bold text-hover-primary lh-base"
                        >
                          <%= course.title %>
                        </a>
                        <!--end::Title-->
    										<!--begin::Text-->
                        <div class="fw-semibold fs-5 text-gray-600 my-4">
                          <%= course.description %>
                        </div>
                        <!--end::Text-->
    										<!--begin::Content-->
                        <div class="fs-6 fw-bold">
                          <!--begin::Date-->
                          <span class="text-muted"><%= format_datetime_crud(course.date) %></span>
                          <!--end::Date-->
                        </div>
                        <!--end::Content-->
                      </div>
                      <!--end::Body-->
                    </div>
                    <!--end::Feature post-->
                  </div>
                  <!--end::Col-->
                <% end %>
              </div>
              <!--end::Row-->
            </div>
            <!--end::Section-->
            <% end %>
          </div>
          <!--end::Body-->
        </div>
        <!--end::Post card-->
      </div>
      <!--end::Container-->
    </div>
    <!--end::Post-->
    """
  end
end
