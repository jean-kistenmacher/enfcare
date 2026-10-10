defmodule AppWeb.ModeloPlanoLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Courses
  import App.Utils

  @impl true
  def mount(params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = Accounts.get_user_by_session_token(user_token)

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

      {:ok,
       assign(socket, current_user: user)
       |> assign(info_page: info_page)
       |> assign(last_courses: last_courses)
       |> assign(list_3_courses: list_3_courses)}
    rescue
      _ -> {:error, redirect(socket, to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <!--begin::Post-->
    <div class="post d-flex flex-column-fluid" id="kt_post">
      <!--begin::Container-->
      <div id="kt_content_container" class="container-xxl">
        <!--begin::Post card-->
        <div class="card">
          <!--begin::Body-->
          <div class="card-body p-lg-20 pb-lg-0">
            <!--begin::Layout-->
            <div class="d-flex flex-column flex-xl-row">
              <!--begin::Content-->
              <div class="flex-lg-row-fluid me-xl-15">
                <!--begin::Post content-->
                <div class="mb-17">
                  <!--begin::Wrapper-->
                  <div class="mb-8">
                    <!--begin::Info-->
                    <div class="d-flex flex-wrap mb-6">
                      <!--begin::Item-->
                      <div class="me-9 my-1">
                      </div>
                      <!--end::Item-->
                    </div>
                    <!--end::Info-->
    									<!--begin::Title-->
                    <span class="text-gray-900 fs-2 fw-bold">Modelo de Plano de Gerenciamento de Resíduos Hospitalares</span>
                    <!--end::Title-->
    									<!--begin::Container-->
                    <div class="overlay mt-8">
                      <a
                        class="d-block overlay"
                        data-fslightbox="lightbox-hot-sales"
                        href={"/images/plano.jpg"}
                      >
                        <!--begin::Image-->
                        <div
                          class="overlay-wrapper bgi-no-repeat bgi-position-center bgi-size-cover card-rounded min-h-350px"
                          style={"background-image:url('/images/plano.jpg')"}
                        >
                        </div>
                        <!--end::Image-->
                            <!--begin::Action-->
                        <div class="overlay-layer card-rounded bg-dark bg-opacity-25">
                          <i class="ki-outline ki-eye fs-2x text-white"></i>
                        </div>
                        <!--end::Action-->
                      </a>
                    </div>
                    <!--end::Container-->
                  </div>
                  <!--end::Wrapper-->
    								<!--begin::Description-->
                  <div class="fs-5 fw-semibold text-gray-600">
                    <!--begin::Text-->
                    <p><strong>Instituição:</strong> [Nome do Hospital/Clínica]</p>
                    <p><strong>Localização:</strong> [Endereço Completo]</p>
                    <p><strong>Responsável pelo Plano:</strong> [Nome do Gestor]</p>
                    <p><strong>Data de Elaboração:</strong> [Data]</p>
                    <p><strong>Validade do Plano:</strong> [Data Final de Validade]</p>
                    <p><strong>Versão:</strong> [Versão Atual]</p>

                    <h2>1. Objetivo</h2>
                    <p>
                      Definir procedimentos para o manejo adequado dos resíduos gerados nas atividades da instituição, visando a redução dos impactos à saúde pública e ao meio ambiente.
                    </p>

                    <h2>2. Estrutura da Gestão de Resíduos</h2>
                    <h3>Classificação dos Resíduos</h3>
                    <ul>
                      <li>
                        <strong>Grupo A:</strong>
                        Resíduos biológicos, incluindo materiais infectantes, patológicos e perfurocortantes.
                      </li>
                      <li>
                        <strong>Grupo B:</strong>
                        Resíduos químicos, como medicamentos vencidos e produtos de limpeza.
                      </li>
                      <li>
                        <strong>Grupo C:</strong> Resíduos radioativos, de tratamentos específicos.
                      </li>
                      <li><strong>Grupo D:</strong> Resíduos comuns, como papéis e plásticos.</li>
                      <li>
                        <strong>Grupo E:</strong> Materiais perfurocortantes (agulhas, lâminas).
                      </li>
                    </ul>

                    <h3>Fontes Geradoras e Quantidade de Resíduos</h3>
                    <ul>
                      <li>
                        [Setor 1 - Ex.: Enfermaria]: Geração média de [X kg] diários do Grupo A.
                      </li>
                      <li>
                        [Setor 2 - Ex.: Laboratório]: Geração média de [Y kg] diários dos Grupos A e B.
                      </li>
                    </ul>
                    <p>
                      <strong>Nota:</strong> Atualizar os dados de geração de resíduos mensalmente.
                    </p>

                    <h3>Responsáveis por Cada Etapa</h3>
                    <ul>
                      <li><strong>Coleta:</strong> [Nome do Responsável/Setor]</li>
                      <li>
                        <strong>Segregação e Identificação:</strong> [Nome do Responsável/Setor]
                      </li>
                      <li><strong>Armazenamento Temporário:</strong> [Nome do Responsável/Setor]</li>
                      <li><strong>Transporte Interno:</strong> [Nome do Responsável/Setor]</li>
                    </ul>

                    <h2>3. Procedimentos Operacionais</h2>

                    <h3>Segregação e Acondicionamento</h3>
                    <ul>
                      <li>
                        <strong>Resíduos do Grupo A:</strong>
                        Utilizar sacos vermelhos e armazenar em local refrigerado a [temperatura] °C.
                      </li>
                      <li>
                        <strong>Resíduos do Grupo B:</strong>
                        Armazenar em recipientes identificados com etiquetas para descarte químico.
                      </li>
                    </ul>
                    <p>
                      <strong>Observação:</strong>
                      Ajustar as normas conforme legislação vigente, que deve ser verificada trimestralmente.
                    </p>

                    <h3>Transporte e Armazenamento</h3>
                    <ul>
                      <li>
                        <strong>Transporte Interno:</strong>
                        Realizar em horário programado (ex.: [horário definido]) com equipamentos de segurança.
                      </li>
                      <li>
                        <strong>Armazenamento Externo:</strong>
                        Manter os resíduos no local de armazenamento por no máximo [X dias] antes da coleta por empresa terceirizada.
                      </li>
                    </ul>

                    <h3>Tratamento e Destinação Final</h3>
                    <ul>
                      <li>
                        <strong>Resíduos Biológicos:</strong>
                        Enviar para incineração em parceria com [Nome da Empresa].
                      </li>
                      <li>
                        <strong>Resíduos Químicos:</strong>
                        Descarte em conformidade com normas de segurança junto à empresa [Nome da Empresa].
                      </li>
                    </ul>

                    <h2>4. Monitoramento e Avaliação</h2>

                    <h3>Avaliação Periódica</h3>
                    <ul>
                      <li>
                        <strong>Periodicidade:</strong>
                        Realizar auditorias a cada [meses/semestre] para avaliação do cumprimento do plano.
                      </li>
                      <li>
                        <strong>Indicadores de Desempenho:</strong>
                        Medir redução de resíduos gerados por setor ([% de Redução de Resíduos]).
                      </li>
                    </ul>

                    <h3>Capacitação dos Funcionários</h3>
                    <p>
                      Programar treinamentos semestrais para os funcionários das áreas de coleta e manuseio.
                    </p>

                    <h2>5. Responsabilidades e Contatos</h2>
                    <p><strong>Gestor do Plano:</strong> [Nome do Gestor], [Contato do Gestor]</p>
                    <p><strong>Equipe de Apoio:</strong> [Listar nomes e setores]</p>

                    <h2>6. Dados Variáveis e Atualizações Necessárias</h2>
                    <ul>
                      <li><strong>Quantidade de Resíduos Gerados:</strong> Atualizar mensalmente.</li>
                      <li>
                        <strong>Treinamentos e Auditorias:</strong>
                        Registrar datas e responsáveis após cada sessão.
                      </li>
                      <li>
                        <strong>Empresas Terceirizadas:</strong>
                        Manter contratos atualizados e verificar conformidade com a legislação.
                      </li>
                    </ul>

                    <h2>7. Assinaturas</h2>
                    <p><strong>Responsável Técnico:</strong> [Nome e Cargo]</p>
                    <p><strong>Gestor Geral do Hospital:</strong> [Nome e Cargo]</p>
                    <!--end::Text-->
                  </div>
                  <!--end::Description-->
                </div>
                <!--end::Post content-->
              </div>
              <!--end::Content-->
    						<!--begin::Sidebar-->
              <div class="flex-column flex-lg-row-auto w-100 w-xl-300px mb-10">
                <!--begin::Recent posts-->
                <div class="m-0">
                  <h4 class="text-gray-900 mb-7">Recentes</h4>
                  <%= for course <- @last_courses do %>
                    <!--begin::Item-->
                    <div class="d-flex flex-stack mb-7">
                      <!--begin::Symbol-->
                      <div class="symbol symbol-60px symbol-2by3 me-4">
                        <div class="symbol-label" style={"background-image: url('#{course.image}')"}>
                        </div>
                      </div>
                      <!--end::Symbol-->
    									<!--begin::Title-->
                      <div class="m-0">
                        <a
                          href={"/show/#{course.id}"}
                          class="text-gray-900 fw-bold text-hover-primary fs-6"
                        >
                          <%= format_title(course.title) %>
                        </a>
                        <span class="text-gray-600 fw-semibold d-block pt-1 fs-7">
                          <%= format_description(course.description) %>
                        </span>
                      </div>
                      <!--end::Title-->
                    </div>
                    <!--end::Item-->
                  <% end %>
                </div>
                <!--end::Recent posts-->
              </div>
              <!--end::Sidebar-->
            </div>
            <!--end::Layout-->
    					<!--begin::Section-->
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
                          class="fs-4 text-gray-900 fw-bold text-hover-primary text-gray-900 lh-base"
                        >
                          <%= course.title %>
                        </a>
                        <!--end::Title-->
    										<!--begin::Text-->
                        <div class="fw-semibold fs-5 text-gray-600 text-gray-900 my-4">
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
