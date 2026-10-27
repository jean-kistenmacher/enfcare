defmodule AppWeb.CursoLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.CourseContent
  alias App.CourseGame
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
           answers: %{},
           quizzes: %{},
           games: load_games(user, item.course, content)
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

  def handle_event("quiz_select", %{"key" => key, "option" => option}, socket) do
    {:noreply,
     update_quiz(socket, key, fn quiz ->
       if MapSet.member?(quiz.validated, quiz.current),
         do: quiz,
         else: %{quiz | selected: Map.put(quiz.selected, quiz.current, option)}
     end)}
  end

  def handle_event("quiz_select", _params, socket), do: {:noreply, socket}

  def handle_event("quiz_validate", %{"key" => key}, socket) do
    {:noreply,
     update_quiz(socket, key, fn quiz ->
       if Map.has_key?(quiz.selected, quiz.current),
         do: %{quiz | validated: MapSet.put(quiz.validated, quiz.current)},
         else: quiz
     end)}
  end

  def handle_event("quiz_next", %{"key" => key}, socket) do
    total = length(CourseContent.quiz_questions(socket.assigns.content, key))

    {:noreply,
     update_quiz(socket, key, fn quiz ->
       if MapSet.member?(quiz.validated, quiz.current) and quiz.current < total - 1,
         do: %{quiz | current: quiz.current + 1},
         else: quiz
     end)}
  end

  def handle_event("quiz_reset", %{"key" => key}, socket) do
    {:noreply, update(socket, :quizzes, &Map.put(&1, key, new_quiz()))}
  end

  def handle_event("game_start", %{"key" => key}, socket) do
    {:noreply, update_game(socket, key, &CourseGame.start/1)}
  end

  def handle_event("game_hint", %{"key" => key}, socket) do
    {:noreply, update_game(socket, key, &CourseGame.hint/1)}
  end

  def handle_event("game_continue", %{"key" => key}, socket) do
    {:noreply, update_game(socket, key, &CourseGame.continue/1)}
  end

  def handle_event("game_select", %{"key" => key} = params, socket) do
    {:noreply, update_game(socket, key, &CourseGame.select(&1, game_value(params)))}
  end

  def handle_event("game_submit", %{"key" => key} = params, socket) do
    {:noreply,
     update_game(socket, key, fn state ->
       CourseGame.submit(state, game_value(params) || state["input"] || "")
     end)}
  end

  def handle_event("complete_module", _params, socket) do
    %{current_user: user, item: item} = socket.assigns

    cond do
      not quizzes_passed?(socket.assigns) ->
        {:noreply,
         put_flash(socket, :error, "Acerte todas as questões da avaliação para concluir o módulo.")}

      not games_finished?(socket.assigns) ->
        {:noreply,
         put_flash(socket, :error, "Finalize a atividade gamificada para concluir o módulo.")}

      true ->
        complete_module(socket, user, item)
    end
  end

  defp game_value(params), do: params["option"] || params["answer"]

  defp load_games(user, course, content) do
    Map.new(CourseContent.games(content), fn key ->
      state =
        case Courses.get_game_attempt(user, course, key) do
          nil -> CourseGame.new_state()
          attempt -> CourseGame.load_state(attempt.state)
        end

      {key, state}
    end)
  end

  # Cada mudança de estado é salva, para que vidas e pontos não sejam recuperados
  # ao recarregar a página. A resposta em edição (`game_select`) só é salva ao enviar.
  defp update_game(socket, key, fun) do
    case socket.assigns.games do
      %{^key => state} ->
        new_state = fun.(state)
        socket = assign(socket, :games, Map.put(socket.assigns.games, key, new_state))
        if new_state == state, do: socket, else: save_game(socket, key, state, new_state)

      _ ->
        socket
    end
  end

  defp save_game(socket, key, state, new_state) do
    if new_state["input"] != state["input"] and new_state["hint"] == state["hint"] and
         new_state["step"] == state["step"] and new_state["feedback"] == state["feedback"] do
      socket
    else
      %{current_user: user, item: item} = socket.assigns

      case Courses.save_game_attempt(user, item.course, key, CourseGame.attempt_attrs(new_state)) do
        {:ok, _attempt} -> socket
        {:error, _changeset} -> put_flash(socket, :error, "Não foi possível salvar seu progresso.")
      end
    end
  end

  defp games_finished?(%{content: content, games: games}) do
    content
    |> CourseContent.games()
    |> Enum.all?(&CourseGame.finished?(Map.fetch!(games, &1)))
  end

  defp complete_module(socket, user, item) do
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

  defp new_quiz, do: %{current: 0, selected: %{}, validated: MapSet.new()}

  defp quiz_score(quiz, questions) do
    questions
    |> Enum.with_index()
    |> Enum.count(fn {q, i} ->
      MapSet.member?(quiz.validated, i) and Map.get(quiz.selected, i) == q.answer
    end)
  end

  defp quizzes_passed?(%{content: content, quizzes: quizzes}) do
    content
    |> CourseContent.quizzes()
    |> Enum.all?(fn {key, questions} ->
      quiz_score(Map.get(quizzes, key, new_quiz()), questions) == length(questions)
    end)
  end

  defp update_quiz(socket, key, fun) do
    update(socket, :quizzes, fn quizzes ->
      Map.update(quizzes, key, fun.(new_quiz()), fun)
    end)
  end

  @impl true
  def render(assigns) do
    assigns =
      assign(assigns,
        next: CourseContent.next_section(assigns.content, assigns.section.slug),
        previous: CourseContent.previous_section(assigns.content, assigns.section.slug),
        requirements_met?: quizzes_passed?(assigns) and games_finished?(assigns)
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

          <.block
            :for={block <- @section.blocks}
            block={block}
            number={@content.number}
            answers={@answers}
            quizzes={@quizzes}
            games={@games}
          />

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
              :if={is_nil(@next) and not @item.completed? and @requirements_met?}
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
  attr :quizzes, :map, default: %{}
  attr :games, :map, default: %{}

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
    block(%{assigns | block: {:figure, file, caption, CourseContent.source()}})
  end

  defp block(%{block: {:figure, file, caption, source}} = assigns) do
    assigns =
      assign(assigns,
        src: CourseContent.figure_path(assigns.number, file),
        caption: caption,
        source: source
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

  defp block(%{block: {:intro_list, html, items}} = assigns) do
    assigns = assign(assigns, html: html, items: items)

    ~H"""
    <div class="curso-list">
      <p class="curso-text curso-list-intro"><%= raw(@html) %></p>
      <ul>
        <li :for={item <- @items}><%= raw(item) %></li>
      </ul>
    </div>
    """
  end

  defp block(%{block: {:table, header, rows}} = assigns) do
    assigns = assign(assigns, header: header, rows: rows)

    ~H"""
    <div class="curso-table-wrapper">
      <table class="curso-table">
        <thead>
          <tr>
            <th :for={cell <- @header} scope="col"><%= cell %></th>
          </tr>
        </thead>
        <tbody>
          <tr :for={row <- @rows}>
            <td :for={cell <- row}><%= cell %></td>
          </tr>
        </tbody>
      </table>
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
        <p :if={Map.get(card, :intro)} class="curso-card-intro"><%= card.intro %></p>
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

  defp block(%{block: {:game, key}} = assigns) do
    assigns = assign(assigns, key: key, state: Map.fetch!(assigns.games, key))

    ~H"""
    <AppWeb.CursoGameComponents.game key={@key} state={@state} />
    """
  end

  defp block(%{block: {:quiz, key, questions, closing}} = assigns) do
    quiz = Map.get(assigns.quizzes, key, new_quiz())
    total = length(questions)
    question = Enum.at(questions, quiz.current)
    validated? = MapSet.member?(quiz.validated, quiz.current)
    last? = quiz.current == total - 1

    score = quiz_score(quiz, questions)

    assigns =
      assign(assigns,
        key: key,
        question: question,
        number: quiz.current + 1,
        total: total,
        selected: Map.get(quiz.selected, quiz.current),
        validated?: validated?,
        finished?: validated? and last?,
        last?: last?,
        score: score,
        perfect?: score == total,
        closing: closing
      )

    ~H"""
    <div id={"quiz-#{@key}"} class="curso-quiz">
      <h2 class="curso-subtitle">Questões de fixação</h2>

      <form id={"quiz-#{@key}-form"} phx-change="quiz_select" phx-submit="quiz_validate">
        <input type="hidden" name="key" value={@key} />
        <p id="quiz-question" class="curso-quiz-question">
          <span><%= @number %>.</span> <%= @question.prompt %>
        </p>

        <label
          :for={{letter, text} <- @question.options}
          class={["curso-quiz-option", @validated? && letter == @question.answer && "is-correct"]}
        >
          <input
            type="radio"
            name="option"
            value={letter}
            checked={@selected == letter}
            disabled={@validated?}
          />
          <span><%= letter %>) <%= text %></span>
        </label>

        <button
          :if={not @validated?}
          type="submit"
          id="quiz-validate"
          class="btn curso-btn-primary curso-quiz-btn"
          disabled={is_nil(@selected)}
        >
          Validar
        </button>
      </form>

      <div :if={@validated?} id="quiz-feedback" class="curso-quiz-feedback">
        <strong>Resposta correta: <%= String.upcase(@question.answer) %></strong>
        <span class="curso-quiz-result">
          <%= if @selected == @question.answer, do: "Você acertou!", else: "Você respondeu #{String.upcase(@selected)}." %>
        </span>
      </div>

      <button
        :if={@validated? and not @last?}
        type="button"
        id="quiz-next"
        class="btn curso-btn-primary curso-quiz-btn"
        phx-click="quiz_next"
        phx-value-key={@key}
      >
        Próxima Questão
      </button>

      <div :if={@finished? and @perfect?} id="quiz-closing" class="curso-quiz-closing">
        <p class="curso-quiz-score">Parabéns! Você acertou <%= @score %> de <%= @total %> questões.</p>
        <p :for={text <- @closing} class="curso-text"><%= text %></p>
      </div>

      <div :if={@finished? and not @perfect?} id="quiz-retry" class="curso-quiz-closing">
        <p class="curso-quiz-score">Você acertou <%= @score %> de <%= @total %> questões.</p>
        <p class="curso-text">Para concluir o módulo, é necessário acertar todas as questões.</p>
        <button
          type="button"
          id="quiz-reset"
          class="btn curso-btn-primary curso-quiz-btn"
          phx-click="quiz_reset"
          phx-value-key={@key}
        >
          Refazer avaliação
        </button>
      </div>
    </div>
    """
  end
end
