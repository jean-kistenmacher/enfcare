defmodule AppWeb.CursoLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.CourseContent
  alias App.Courses

  @impl true
  def mount(%{"id" => id}, session, socket) do
    user = Accounts.get_user_by_session_token(Map.get(session, "user_token"))

    with {course_id, ""} <- Integer.parse(id),
         %{} = item <- Courses.get_module_with_status(user, course_id),
         %{} = content <- CourseContent.get(item.number) do
      if item.unlocked? do
        {:ok,
         assign(socket,
           current_user: user,
           item: item,
           content: content,
           answers: %{}
         )}
      else
        {:ok,
         socket
         |> put_flash(:error, "Conclua o módulo anterior para acessar este conteúdo.")
         |> redirect(to: "/")}
      end
    else
      _ -> {:ok, socket |> put_flash(:error, "Módulo não encontrado.") |> redirect(to: "/")}
    end
  end

  @impl true
  def handle_params(params, _uri, socket) do
    section = CourseContent.find_section(socket.assigns.content, params["secao"])
    {:noreply, assign(socket, section: section, page_title: section.title)}
  end

  @impl true
  def handle_event("save_answer", %{"key" => key, "answer" => answer}, socket) do
    {:noreply, update(socket, :answers, &Map.put(&1, key, answer))}
  end

  def handle_event("complete_module", _params, socket) do
    %{current_user: user, item: item} = socket.assigns

    case Courses.complete_course(user, item.course) do
      {:ok, _completion} ->
        {:noreply,
         socket
         |> put_flash(:info, "Módulo concluído! O próximo módulo foi liberado.")
         |> redirect(to: "/")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Não foi possível concluir o módulo.")}
    end
  end

  @impl true
  def render(assigns) do
    assigns =
      assign(assigns,
        next: CourseContent.next_section(assigns.content, assigns.section.slug),
        previous: CourseContent.previous_section(assigns.content, assigns.section.slug)
      )

    ~H"""
    <div id="curso-layout" class="curso-layout">
      <.flash_group flash={@flash} id={"app-page-#{System.unique_integer([:positive]) |> Integer.to_string()}"} />

      <aside id="curso-aside" class="curso-aside">
        <button
          type="button"
          id="curso-aside-toggle"
          class="curso-aside-toggle"
          aria-label="Recolher ou expandir sessões"
          phx-click={JS.toggle_class("curso-aside-collapsed", to: "#curso-layout")}
        >
          <i class="ki-outline ki-double-left fs-2"></i>
        </button>

        <div class="curso-aside-body">
          <h2 class="curso-aside-title"><%= @content.title %></h2>
          <div class="curso-aside-subtitle"><%= @content.subtitle %></div>

          <nav aria-label="Sessões do curso">
            <ol class="curso-aside-list">
              <li
                :for={{section, index} <- Enum.with_index(@content.sections, 1)}
                class={["curso-aside-item", section.slug == @section.slug && "active"]}
              >
                <.link
                  patch={~p"/cursos/#{@item.course.id}?secao=#{section.slug}"}
                  id={"curso-section-#{section.slug}"}
                  aria-current={section.slug == @section.slug && "page"}
                >
                  <span class="curso-aside-number"><%= index %></span>
                  <span><%= section.title %></span>
                </.link>
              </li>
            </ol>
          </nav>
        </div>
      </aside>

      <main id="curso-main" class="curso-main" phx-hook="CursoConteudo" data-secao={@section.slug}>
        <article class="curso-article">
          <h1 id="curso-section-title" class="curso-heading"><%= @section.heading %></h1>

          <.block :for={block <- @section.blocks} block={block} number={@content.number} answers={@answers} />

          <div class="curso-pager">
            <.link
              :if={@previous}
              patch={~p"/cursos/#{@item.course.id}?secao=#{@previous.slug}"}
              id="curso-prev"
              class="btn btn-light-primary curso-pager-btn"
            >
              Sessão Anterior
            </.link>
            <.link
              :if={@next}
              patch={~p"/cursos/#{@item.course.id}?secao=#{@next.slug}"}
              id="curso-next"
              class="btn curso-btn-primary curso-pager-btn"
            >
              Próxima Sessão
            </.link>
            <button
              :if={is_nil(@next) and not @item.completed?}
              type="button"
              id="curso-complete"
              class="btn curso-btn-primary curso-pager-btn"
              phx-click="complete_module"
            >
              Concluir Curso
            </button>
            <.link
              :if={is_nil(@next) and @item.completed?}
              navigate={~p"/"}
              id="curso-back"
              class="btn curso-btn-primary curso-pager-btn"
            >
              Voltar aos Módulos
            </.link>
          </div>
        </article>
      </main>
    </div>
    """
  end

  attr :block, :any, required: true
  attr :number, :integer, required: true
  attr :answers, :map, required: true

  defp block(%{block: {:paragraph, html}} = assigns) do
    assigns = assign(assigns, :html, html)

    ~H"""
    <p class="curso-text"><%= raw(@html) %></p>
    """
  end

  defp block(%{block: {:subtitle, text}} = assigns) do
    assigns = assign(assigns, :text, text)

    ~H"""
    <h2 class="curso-subtitle"><%= @text %></h2>
    """
  end

  defp block(%{block: {:figure, file, caption}} = assigns) do
    assigns =
      assign(assigns,
        src: CourseContent.figure_path(assigns.number, file),
        caption: caption,
        source: CourseContent.source()
      )

    ~H"""
    <figure class="curso-figure">
      <img src={@src} alt={@caption} loading="lazy" />
      <figcaption>
        <strong><%= @caption %></strong>
        <span><%= @source %></span>
      </figcaption>
    </figure>
    """
  end

  defp block(%{block: {:list, title, items}} = assigns) do
    assigns = assign(assigns, title: title, items: items)

    ~H"""
    <div class="curso-list">
      <h2 :if={@title} class="curso-subtitle"><%= @title %></h2>
      <ul>
        <li :for={item <- @items}><%= raw(item) %></li>
      </ul>
    </div>
    """
  end

  defp block(%{block: {:callout, label, text}} = assigns) do
    assigns = assign(assigns, label: label, text: text)

    ~H"""
    <div class="curso-callout">
      <strong><%= @label %>:</strong> <%= @text %>
    </div>
    """
  end

  defp block(%{block: {:cards, cards}} = assigns) do
    assigns = assign(assigns, :cards, cards)

    ~H"""
    <div class="curso-cards">
      <section :for={card <- @cards} class="curso-card">
        <h3><%= card.title %></h3>
        <ul>
          <li :for={item <- card.items}><%= item %></li>
        </ul>
      </section>
    </div>
    """
  end

  defp block(%{block: {:references, items}} = assigns) do
    assigns = assign(assigns, :items, items)

    ~H"""
    <ul class="curso-references">
      <li :for={item <- @items}><%= raw(item) %></li>
    </ul>
    """
  end

  defp block(%{block: {:reflection, key, prompt}} = assigns) do
    assigns = assign(assigns, key: key, prompt: prompt, value: Map.get(assigns.answers, key, ""))

    ~H"""
    <form id={"reflection-#{@key}"} class="curso-reflection" phx-change="save_answer" phx-submit="save_answer">
      <input type="hidden" name="key" value={@key} />
      <div class="curso-reflection-label">Autorreflexão</div>
      <label for={"answer-#{@key}"} class="curso-text"><%= @prompt %></label>
      <textarea id={"answer-#{@key}"} name="answer" rows="4" phx-debounce="400"><%= @value %></textarea>
    </form>
    """
  end
end
