defmodule AppWeb.ModuloLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Courses

  @module_content %{
    1 => %{
      description: "Neste módulo, você compreenderá como a resistência antimicrobiana (RAM) se desenvolve, quais são seus impactos na assistência em saúde e qual o papel da enfermagem na prevenção e controle desse fenômeno.",
      activities: [
        "Leitura guiada;",
        "Momentos de reflexão;",
        "Atividades interativas;",
        "Análise de caso clínico;",
        "Uso orientado de chatbot educacional;",
        "Avaliação de aprendizagem"
      ],
      objectives: [
        "Compreender o conceito de RAM;",
        "Identificar fatores relacionados ao desenvolvimento da RAM;",
        "Reconhecer mecanismos básicos de RAM;",
        "Relacionar RAM, infecções relacionadas à assistência à saúde e segurança do paciente;",
        "Refletir sobre a atuação da enfermagem no controle da RAM."
      ],
      competencies: [
        "Desenvolvimento do pensamento crítico e raciocínio clínico;",
        "Análise epidemiológica aplicada à prática em saúde;",
        "Planejamento de ações educativas voltadas à prevenção da RAM;",
        "Promoção da segurança do paciente e prevenção de IRAS;",
        "Tomada de decisão baseada em evidências científicas e boas práticas assistenciais."
      ],
      workload: "2 horas"
    },
    2 => %{
      description: "Neste módulo, você conhecerá os principais mecanismos de ação e classes de antibióticos utilizados na prática hospitalar, bem como os cuidados necessários para sua administração segura.
      Serão abordados a Concentração Inibitória Mínima (CIM), o cumprimento dos horários, o aprazamento, as incompatibilidades, os nove certos da administração de medicamentos e o monitoramento de efeitos adversos e da resposta terapêutica.
      Ao longo do módulo, você assumirá o papel de enfermeiro em um plantão simulado, analisando prescrições e tomando decisões relacionadas à segurança da antibioticoterapia.
      ",
      activities: [
        "Leitura guiada",
        "Momentos de reflexão",
        "Atividades interativas",
        "Análise de caso clínico",
        "Uso orientado de chatbot educacional",
        "Atividade gamificada baseada em escolhas",
        "Avaliação de aprendizagem"
      ],
      objectives: [
        "Reconhecer os principais mecanismos de ação e classes de antibióticos",
        "Explicar a importância da CIM e dos horários de administração",
        "Aplicar os princípios do aprazamento seguro",
        "Diferenciar interação medicamentosa de incompatibilidade físico-química",
        "Aplicar os nove certos da administração de medicamentos",
        "Reconhecer efeitos adversos, toxicidades e sinais de resposta clínica inadequada",
        "Identificar as condutas iniciais de Enfermagem diante de intercorrências",
        "Compreender a participação da Enfermagem no uso seguro e racional dos antibióticos"
      ],
      competencies: [
        "Administração segura de antibióticos",
        "Identificação de riscos relacionados ao preparo, aprazamento e administração",
        "Monitoramento da resposta terapêutica e dos eventos adversos",
        "Raciocínio clínico e tomada de decisão",
        "Comunicação com a equipe multiprofissional",
        "Atuação baseada em evidências e na segurança do paciente"
      ],
      workload: "3 horas"
    }
  }

  @impl true
  def mount(%{"id" => id}, session, socket) do
    user = Accounts.get_user_by_session_token(Map.get(session, "user_token"))

    with {course_id, ""} <- Integer.parse(id),
         %{} = item <- Courses.get_module_with_status(user, course_id) do
      content = Map.get(@module_content, item.number, %{})
      {:ok, assign(socket, current_user: user, item: item, content: content)}
    else
      _ -> {:ok, socket |> put_flash(:error, "Módulo não encontrado.") |> redirect(to: "/")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="d-flex flex-column flex-root">
      <.flash_group flash={@flash} id={"app-page-#{System.unique_integer([:positive]) |> Integer.to_string()}"} />

      <div class="page d-flex flex-column flex-column-fluid">
        <div class="d-flex flex-column flex-row-fluid" id="kt_wrapper">
          <div class="content d-flex flex-column flex-column-fluid px-lg-12 py-5">
            <div class="container-fluid">
              <div class="row mb-8">
                <div class="col-12">
                  <h1 class="display-4 fw-bold text-gray-900 mb-2">Módulo <%= @item.number %></h1>
                  <h2 class="fs-3 fw-bold text-gray-700"><%= @item.course.title %></h2>
                </div>
              </div>

              <div class="row mb-10">
                <div class="col-12">
                  <div class="bg-light-secondary d-flex align-items-center justify-content-right overflow-hidden rounded-2" style="height: 280px;">
                    <%= if @item.course.image && @item.course.image != "" do %>
                      <img src={"/images/cursos/#{@item.course.image}/banner.png"} alt={@item.course.title} class="w-auto" style="" />
                    <% else %>
                      <div class="text-center">
                        <i class="ki-outline ki-picture text-gray-500" style="font-size: 5rem;"></i>
                        <div class="fs-6 text-gray-600 mt-3">Imagem Apresentação</div>
                      </div>
                    <% end %>
                  </div>
                </div>
              </div>

              <div class="row mb-8">
                <div class="col-12">
                  <div class="fs-2 text-gray-900 lh-lg">
                    <%= @content[:description] %>
                  </div>
                </div>
              </div>

              <%= if @content[:activities] do %>
                <div class="row mb-8">
                  <div class="col-12">
                    <h3 class="fs-2 fw-bold text-gray-900 mb-5">AO LONGO DO CONTEÚDO, VOCÊ REALIZARÁ</h3>
                    <div class="fs-4 text-gray-800 lh-lg">
                      <ul>
                        <%= for activity <- @content[:activities] do %>
                          <li class="mb-2"><%= activity %></li>
                        <% end %>
                      </ul>
                    </div>
                  </div>
                </div>
              <% end %>

              <%= if @content[:objectives] do %>
                <div class="row mb-8">
                  <div class="col-12">
                    <h3 class="fs-2 fw-bold text-gray-900 mb-5">OBJETIVOS DE APRENDIZAGEM</h3>
                    <div class="fs-4 text-gray-800 lh-lg">
                      Ao finalizar este módulo, você deverá ser capaz de:
                      <ul class="mt-3">
                        <%= for objective <- @content[:objectives] do %>
                          <li class="mb-2"><%= objective %></li>
                        <% end %>
                      </ul>
                    </div>
                  </div>
                </div>
              <% end %>

              <%= if @content[:competencies] do %>
                <div class="row mb-8">
                  <div class="col-12">
                    <h3 class="fs-2 fw-bold text-gray-900 mb-5">COMPETÊNCIAS DESENVOLVIDAS</h3>
                    <div class="fs-4 text-gray-800 lh-lg">
                      <ul>
                        <%= for competency <- @content[:competencies] do %>
                          <li class="mb-2"><%= competency %></li>
                        <% end %>
                      </ul>
                    </div>
                  </div>
                </div>
              <% end %>

              <%= if @content[:workload] do %>
                <div class="row mb-8">
                  <div class="col-12">
                    <h4 class="fs-5 fw-bold text-gray-900">Carga Horária: <%= @content[:workload] %></h4>
                  </div>
                </div>
              <% end %>

              <div class="row">
                <div class="col-12">
                  <div class="d-flex gap-3">
                    <a href="/" class="btn btn-light-primary btn-xl px-6 py-3" style="white-space: nowrap;">
                      <i class="ki-outline ki-arrow-left fs-5 me-2"></i>Voltar
                    </a>
                    <%= if @item.unlocked? do %>
                      <.link navigate={App.CourseContent.start_path(@item)} id="module-start" class="btn btn-success btn-xl px-6 py-3">
                        <%= if @item.completed?, do: "Revisar", else: "Iniciar" %>
                      </.link>
                    <% else %>
                      <button type="button" id="module-start" class="btn btn-secondary btn-xl px-6 py-3" disabled>
                        <i class="ki-outline ki-lock fs-6 me-2"></i>Iniciar
                      </button>
                    <% end %>
                  </div>
                  <%= if !@item.unlocked? do %>
                    <div class="text-muted fs-6 mt-4">
                      <%= if @item.requires do %>
                        Conclua <strong><%= @item.requires.title %></strong> para liberar este conteúdo.
                      <% end %>
                    </div>
                  <% end %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
