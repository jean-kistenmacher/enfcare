defmodule AppWeb.CursoGameComponents do
  @moduledoc """
  Interface da atividade gamificada dos módulos (ver `App.CourseGame`).

  Os eventos (`game_start`, `game_select`, `game_submit`, `game_hint` e
  `game_continue`) são tratados por `AppWeb.CursoLive`.
  """

  use Phoenix.Component

  alias App.CourseGame

  attr :key, :string, required: true
  attr :state, :map, required: true

  def game(assigns) do
    assigns = assign(assigns, step: CourseGame.current(assigns.state))

    ~H"""
    <div id={"game-#{@key}"} class="curso-game">
      <%= cond do %>
        <% CourseGame.finished?(@state) -> %>
          <.summary key={@key} summary={CourseGame.summary(@state)} />
        <% @state["brief"] -> %>
          <.brief key={@key} state={@state} step={@step} />
        <% true -> %>
          <.question key={@key} state={@state} step={@step} />
      <% end %>
    </div>
    """
  end

  attr :key, :string, required: true
  attr :state, :map, required: true
  attr :step, :map, required: true

  defp brief(assigns) do
    assigns = assign(assigns, phase: CourseGame.phase(assigns.step.phase), first?: assigns.state["step"] == 0)

    ~H"""
    <section id="game-brief" class="curso-game-brief">
      <p :if={@first?} class="curso-text">
        Você vai atuar como enfermeiro(a) em um plantão simulado. Teste seus conhecimentos sobre a
        administração segura de antibióticos, acumule pontos e conquiste o seu distintivo.
      </p>

      <div :if={@first?} class="curso-callout">
        <strong>Regras do jogo:</strong>
        <ul>
          <li>Você tem <%= CourseGame.lives() %> vidas, que valem nas Fases 2 e 3. Cada erro custa uma vida; sem vidas, o jogo termina.</li>
          <li>Cada acerto vale pontos, e acertos consecutivos geram bônus.</li>
          <li>Você pode pedir dicas, mas perde pontos ao usá-las.</li>
          <li>A atividade só pode ser jogada uma vez e é necessária para concluir o módulo.</li>
        </ul>
      </div>

      <h2 class="curso-subtitle"><%= @phase.title %> (<%= @phase.minutes %> minutos)</h2>
      <p class="curso-text"><%= @phase.description %></p>

      <div :if={@step.phase != "pretest"} class="curso-game-stats">
        <.stats state={@state} />
      </div>

      <button
        type="button"
        id="game-start"
        class="btn curso-btn-primary curso-quiz-btn"
        phx-click="game_start"
        phx-value-key={@key}
      >
        <%= if @step.phase == "pretest", do: "Começar o Pré-teste", else: "Iniciar fase" %>
      </button>
    </section>
    """
  end

  attr :state, :map, required: true

  defp stats(assigns) do
    ~H"""
    <span id="game-points" class="curso-game-stat"><strong><%= @state["points"] %></strong> pontos</span>
    <span id="game-lives" class="curso-game-stat curso-game-lives" aria-label={"#{@state["lives"]} vidas"}>
      <span :for={n <- 1..CourseGame.lives()} class={n > @state["lives"] && "is-lost"}>♥</span>
    </span>
    <span :if={@state["streak"] > 1} id="game-streak" class="curso-game-stat">
      Sequência: <strong><%= @state["streak"] %></strong>
    </span>
    """
  end

  attr :key, :string, required: true
  attr :state, :map, required: true
  attr :step, :map, required: true

  defp question(assigns) do
    steps = CourseGame.steps()
    same_phase = Enum.filter(steps, &(&1.phase == assigns.step.phase))
    feedback = assigns.state["feedback"]

    assigns =
      assign(assigns,
        phase: CourseGame.phase(assigns.step.phase),
        percent: round(assigns.state["step"] * 100 / length(steps)),
        number: Enum.find_index(same_phase, &(&1.id == assigns.step.id)) + 1,
        total: length(same_phase),
        feedback: feedback,
        selected: (feedback && feedback["answer"]) || assigns.state["input"],
        last?: assigns.state["step"] == length(steps) - 1
      )

    ~H"""
    <section id="game-question">
      <div class="curso-game-hud">
        <div class="curso-game-progress" role="progressbar" aria-valuenow={@percent} aria-valuemin="0" aria-valuemax="100">
          <div class="curso-game-progress-bar" style={"width: #{@percent}%"}></div>
        </div>
        <div :if={@step.phase != "pretest"} class="curso-game-stats">
          <.stats state={@state} />
        </div>
      </div>

      <div class="curso-game-phase"><%= @phase.title %> · Questão <%= @number %> de <%= @total %></div>

      <div :if={@step.kind == :choice} class="curso-game-case">
        <h2 class="curso-subtitle"><%= @step.title %></h2>
        <p class="curso-text"><%= @step.patient %></p>
        <p class="curso-text"><strong>O desafio:</strong> <%= @step.challenge %></p>
      </div>

      <div :if={@step.kind == :certos} class="curso-game-case">
        <h2 class="curso-subtitle"><%= @step.title %></h2>
        <div class="curso-game-docs">
          <.document title="Prescrição médica" rows={@step.prescription} />
          <.document title="Checagem de enfermagem" rows={@step.check} />
        </div>
      </div>

      <form id={"game-#{@key}-form"} phx-change="game_select" phx-submit="game_submit">
        <input type="hidden" name="key" value={@key} />
        <p id="game-prompt" class="curso-quiz-question"><%= @step.prompt %></p>

        <textarea
          :if={@step.kind == :text}
          id="game-answer"
          name="answer"
          rows="4"
          placeholder="Escreva sua resposta"
          disabled={@feedback != nil}
          phx-debounce="400"
        ><%= @selected %></textarea>

        <div :if={@step.kind != :text} class={["curso-game-options", @step.kind == :certos && "is-grid"]}>
          <label
            :for={{value, text} <- @step.options}
            class={["curso-quiz-option", @feedback && value == answer_of(@step) && "is-correct"]}
          >
            <input type="radio" name="option" value={value} checked={@selected == value} disabled={@feedback != nil} />
            <span><%= if @step.kind in [:pretest, :choice], do: "#{value}) #{text}", else: text %></span>
          </label>
        </div>

        <div :if={@feedback == nil} class="curso-game-actions">
          <button type="submit" id="game-submit" class="btn curso-btn-primary curso-quiz-btn">
            <%= if @step.kind == :pretest, do: "Responder", else: "Validar" %>
          </button>
          <button
            :if={@step.kind != :pretest and not @state["hint"]}
            type="button"
            id="game-hint"
            class="btn btn-light-primary curso-quiz-btn"
            phx-click="game_hint"
            phx-value-key={@key}
          >
            Pedir dica (-<%= @step.hint_cost %> pontos)
          </button>
        </div>
      </form>

      <div :if={@state["hint"] and @feedback == nil} id="game-hint-text" class="curso-callout">
        <strong>Dica:</strong> <%= @step.hint %>
      </div>

      <.feedback :if={@feedback} key={@key} state={@state} step={@step} last?={@last?} />
    </section>
    """
  end

  defp answer_of(%{kind: :text}), do: nil
  defp answer_of(step), do: step.answer

  attr :title, :string, required: true
  attr :rows, :list, required: true

  defp document(assigns) do
    ~H"""
    <div class="curso-game-doc">
      <h3><%= @title %></h3>
      <dl>
        <div :for={{label, value} <- @rows}>
          <dt><%= label %></dt>
          <dd><%= value %></dd>
        </div>
      </dl>
    </div>
    """
  end

  attr :key, :string, required: true
  attr :state, :map, required: true
  attr :step, :map, required: true
  attr :last?, :boolean, required: true

  defp feedback(assigns) do
    feedback = assigns.state["feedback"]
    step = assigns.step

    assigns =
      assign(assigns,
        correct?: feedback["correct"],
        gained: feedback["points"],
        game_over?: assigns.state["status"] == "game_over",
        text: feedback_text(step, feedback["correct"]),
        reference: reference(step)
      )

    ~H"""
    <div id="game-feedback" class={["curso-quiz-feedback", @correct? && "is-correct", not @correct? && "is-wrong"]}>
      <strong><%= if @correct?, do: "Você acertou!", else: "Resposta incorreta." %></strong>
      <span :if={@correct?} class="curso-quiz-result">+<%= @gained %> pontos</span>
      <span :if={not @correct? and @step.lives?} class="curso-quiz-result">Você perdeu uma vida.</span>
      <p :if={@text} class="curso-text"><%= @text %></p>
      <p :if={@reference} class="curso-text"><strong><%= elem(@reference, 0) %>:</strong> <%= elem(@reference, 1) %></p>
      <p :if={@game_over?} id="game-over" class="curso-text">
        <strong>Suas vidas acabaram.</strong> Veja o resumo do seu desempenho para fechar as lacunas.
      </p>
    </div>

    <button
      type="button"
      id="game-continue"
      class="btn curso-btn-primary curso-quiz-btn"
      phx-click="game_continue"
      phx-value-key={@key}
    >
      <%= if @game_over? or @last?, do: "Ver meu desempenho", else: "Continuar" %>
    </button>
    """
  end

  defp feedback_text(%{kind: :text}, true), do: nil
  defp feedback_text(%{kind: :text} = step, false), do: step.hint
  defp feedback_text(step, true), do: step.correct_feedback
  defp feedback_text(step, false), do: step.wrong_feedback

  defp reference(%{kind: :text} = step), do: {"Resposta de referência", step.expected}

  defp reference(%{options: options, answer: answer}) do
    {_key, text} = Enum.find(options, fn {key, _} -> key == answer end)
    {"Resposta correta", text}
  end

  attr :key, :string, required: true
  attr :summary, :map, required: true

  defp summary(assigns) do
    ~H"""
    <section id="game-summary" class="curso-game-summary">
      <div class="curso-game-badge">
        <div class="curso-game-badge-icon" aria-hidden="true"><%= @summary.level.icon %></div>
        <div>
          <div class="curso-game-phase">Seu distintivo</div>
          <h2 id="game-level" class="curso-subtitle"><%= @summary.level.name %></h2>
          <p class="curso-text"><%= @summary.level.description %></p>
        </div>
      </div>

      <p id="game-final-points" class="curso-quiz-score">
        <%= @summary.points %> de <%= @summary.max_points %> pontos
      </p>

      <p :if={@summary.game_over?} class="curso-text">
        Suas vidas acabaram antes do final do plantão. Revise os pontos abaixo e retome o conteúdo do módulo.
      </p>
      <p :if={not @summary.game_over?} class="curso-text">
        Parabéns, Enfermeiro(a)! Fechar o cerco contra a Resistência Antimicrobiana não depende apenas da
        descoberta de novos remédios, mas do rigor técnico na beira do leito. Administrar a dose certa, no
        tempo certo e pela via correta impede subdosagens e falhas que alimentam a pressão seletiva das
        superbactérias.
      </p>

      <h2 class="curso-subtitle">Placar final</h2>
      <.meter id="game-effectiveness" label="Eficácia Terapêutica" value={@summary.effectiveness} />
      <.meter id="game-safety" label="Segurança do Paciente" value={@summary.safety} />

      <h2 class="curso-subtitle">Seu desempenho</h2>
      <div class="curso-cards">
        <section class="curso-card">
          <h3>Pré-teste</h3>
          <p id="game-pretest" class="curso-text"><%= @summary.pretest.correct %> de <%= @summary.pretest.total %> acertos</p>
        </section>
        <section :for={phase <- @summary.phases} class="curso-card">
          <h3><%= phase.title %></h3>
          <p class="curso-text"><%= phase.correct %> de <%= phase.total %> acertos</p>
        </section>
      </div>

      <div :if={@summary.strengths != []} id="game-strengths">
        <h2 class="curso-subtitle">Onde você mais acertou</h2>
        <div class="curso-list">
          <ul>
            <li :for={topic <- @summary.strengths}><%= topic %></li>
          </ul>
        </div>
      </div>

      <div :if={@summary.review != []} id="game-review">
        <h2 class="curso-subtitle">Onde revisar</h2>
        <div class="curso-list">
          <ul>
            <li :for={item <- @summary.review}>
              <strong><%= item.topic %></strong><%= if not item.answered?, do: " (não alcançado)" %><br />
              <%= item.explanation %>
            </li>
          </ul>
        </div>
      </div>

      <div :if={@summary.review == []} class="curso-callout">
        <strong>Sem lacunas:</strong> você acertou todas as questões e decisões da atividade.
      </div>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :value, :integer, required: true

  defp meter(assigns) do
    ~H"""
    <div id={@id} class="curso-game-meter">
      <div class="curso-game-meter-label"><span><%= @label %></span><strong><%= @value %>%</strong></div>
      <div class="curso-game-progress">
        <div class="curso-game-progress-bar" style={"width: #{@value}%"}></div>
      </div>
    </div>
    """
  end
end
