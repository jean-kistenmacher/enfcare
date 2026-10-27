defmodule App.CourseGame do
  @moduledoc """
  Motor da atividade gamificada do módulo (pré-teste, 3 fases e feedback reflexivo).

  O estado do jogo é um mapa com chaves em texto e valores simples (compatível com
  JSON), para ser guardado em `App.Courses.GameAttempt`:

    * `"step"` - posição na lista de `steps/0`;
    * `"brief"` - `true` enquanto o aluno lê a apresentação de uma fase;
    * `"lives"`, `"points"`, `"streak"` - vidas, pontos e acertos consecutivos;
    * `"hint"`, `"input"`, `"feedback"` - dica pedida, resposta em edição e resultado
      do item atual (aguardando "continuar");
    * `"status"` - `"playing"`, `"finished"` ou `"game_over"`;
    * `"pretest"` e `"log"` - respostas do pré-teste e resultado de cada item pontuado.

  Regras: o pré-teste não pontua e não tem feedback. Cada acerto vale os pontos do
  item mais um bônus por acertos consecutivos; pedir dica reduz os pontos do item.
  As vidas valem nas fases 2 e 3 e, ao acabarem, o jogo termina.
  """

  alias App.CourseGame.Content

  @lives 3
  @streak_bonus 5
  @max_streak_steps 4

  @phases [
    %{
      id: "pretest",
      title: "Pré-teste",
      minutes: 10,
      description:
        "10 questões de múltipla escolha para mapear o que você já sabe. Não há feedback nem pontuação nesta etapa."
    },
    %{
      id: "f1",
      title: "Fase 1 - Aquecimento",
      minutes: 10,
      description:
        "5 cenários da atuação da enfermagem. Escreva uma resposta curta para cada um. Se errar, uma dica explica o conceito antes de avançar."
    },
    %{
      id: "f2",
      title: "Fase 2 - Casos clínicos e tomada de decisões",
      minutes: 25,
      description:
        "Simulação com 3 pacientes em sequência, com complexidade crescente. A partir desta fase, cada erro custa uma vida."
    },
    %{
      id: "f3",
      title: "Fase 3 - Os 13 certos e a prevenção da resistência antimicrobiana",
      minutes: 10,
      description:
        "Você verá uma prescrição e a checagem de enfermagem correspondente e deverá apontar qual dos 13 certos foi violado. Cada erro custa uma vida."
    }
  ]

  @levels [
    %{
      id: "especialista-ram",
      name: "Especialista em RAM",
      icon: "🏆",
      description: "Acertou 100% das questões e decisões da atividade."
    },
    %{
      id: "especialista-pga",
      name: "Especialista em PGA",
      icon: "🥇",
      description: "Alcançou pelo menos 70% dos pontos possíveis."
    },
    %{
      id: "sentinela",
      name: "Sentinela da Segurança",
      icon: "🛡️",
      description: "Alcançou pelo menos 40% dos pontos possíveis."
    },
    %{
      id: "aprendiz",
      name: "Aprendiz da Segurança",
      icon: "🎖️",
      description: "Continue estudando o módulo para subir de nível."
    }
  ]

  def lives, do: @lives
  def phases, do: @phases
  def levels, do: @levels

  @doc "Informações da fase `id`."
  def phase(id), do: Enum.find(@phases, &(&1.id == id))

  @doc "Lista ordenada de todos os itens do jogo."
  def steps do
    pretest = for q <- Content.pretest(), do: Map.merge(q, %{kind: :pretest, phase: "pretest"})

    f1 =
      for q <- Content.phase1(),
          do: Map.merge(q, %{kind: :text, phase: "f1", points: 10, hint_cost: 4, lives?: false})

    f2 =
      for q <- Content.phase2(),
          do: Map.merge(q, %{kind: :choice, phase: "f2", points: 20, hint_cost: 8, lives?: true})

    f3 =
      for q <- Content.phase3(),
          do:
            Map.merge(q, %{
              kind: :certos,
              phase: "f3",
              points: 20,
              hint_cost: 8,
              lives?: true,
              prompt: "Qual dos 13 certos foi violado?",
              options: Content.certos()
            })

    pretest ++ f1 ++ f2 ++ f3
  end

  @doc "Itens que pontuam (todos, exceto o pré-teste)."
  def scored_steps, do: Enum.reject(steps(), &(&1.kind == :pretest))

  @doc "Estado inicial."
  def new_state do
    %{
      "step" => 0,
      "brief" => true,
      "lives" => @lives,
      "points" => 0,
      "streak" => 0,
      "hint" => false,
      "input" => nil,
      "feedback" => nil,
      "status" => "playing",
      "pretest" => %{},
      "log" => []
    }
  end

  @doc "Completa um estado carregado do banco com os valores padrão."
  def load_state(state) when is_map(state), do: Map.merge(new_state(), state)

  @doc "Item atual, ou `nil` quando o jogo terminou."
  def current(state), do: Enum.at(steps(), state["step"])

  @doc "O aluno já terminou o jogo (concluiu todas as fases ou perdeu todas as vidas)?"
  def finished?(%{"status" => "finished"}), do: true
  def finished?(%{"status" => "game_over", "feedback" => nil}), do: true
  def finished?(_state), do: false

  @doc "Passa da apresentação da fase para o primeiro item."
  def start(%{"brief" => true, "status" => "playing"} = state), do: %{state | "brief" => false}
  def start(state), do: state

  @doc "Guarda a resposta em edição do item atual."
  def select(state, value) when is_binary(value) do
    if answerable?(state), do: Map.put(state, "input", value), else: state
  end

  @doc "Pede a dica do item atual, o que reduz os pontos que ele vale."
  def hint(state) do
    case current(state) do
      %{kind: kind} when kind != :pretest ->
        if answerable?(state), do: %{state | "hint" => true}, else: state

      _ ->
        state
    end
  end

  @doc "Envia a resposta do item atual."
  def submit(state, value) when is_binary(value) do
    step = current(state)

    cond do
      step == nil or not answerable?(state) -> state
      step.kind == :pretest -> submit_pretest(state, step, value)
      step.kind == :text -> resolve(state, step, String.trim(value), correct_text?(value, step))
      true -> submit_choice(state, step, value)
    end
  end

  @doc "Avança depois de ler o feedback do item."
  def continue(%{"feedback" => nil} = state), do: state

  def continue(state) do
    state = %{state | "feedback" => nil, "hint" => false, "input" => nil}
    if state["status"] == "game_over", do: state, else: advance(state)
  end

  @doc "Pontos máximos possíveis (todos os acertos, sem dicas)."
  def max_points do
    {total, _streak} =
      Enum.reduce(scored_steps(), {0, 0}, fn step, {sum, streak} ->
        streak = streak + 1
        {sum + step.points + streak_bonus(streak), streak}
      end)

    total
  end

  @doc "Resumo do desempenho, usado na tela de feedback reflexivo e no ranking."
  def summary(state) do
    scored = scored_steps()
    log = Map.new(state["log"], &{&1["id"], &1})
    points = state["points"]
    perfect? = Enum.all?(scored, &(get_in(log, [&1.id, "correct"]) == true))

    %{
      points: points,
      max_points: max_points(),
      level: level(points, perfect?),
      game_over?: state["status"] == "game_over",
      lives: state["lives"],
      effectiveness: axis_percent(scored, log, :effectiveness),
      safety: axis_percent(scored, log, :safety),
      pretest: pretest_score(state),
      phases: phase_results(scored, log),
      strengths: for(s <- scored, get_in(log, [s.id, "correct"]) == true, do: s.topic),
      review: review_items(scored, log)
    }
  end

  @doc """
  Atributos para salvar a tentativa em `App.Courses.save_game_attempt/4`.

  O status da tentativa só deixa de ser `"playing"` quando o jogo termina de fato
  (`finished?/1`), pois uma tentativa finalizada não pode mais ser alterada.
  """
  def attempt_attrs(state) do
    if finished?(state) do
      summary = summary(state)

      %{
        state: state,
        status: state["status"],
        points: state["points"],
        level: summary.level.id,
        effectiveness: summary.effectiveness,
        safety: summary.safety,
        finished_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }
    else
      %{state: state, status: "playing", points: state["points"]}
    end
  end

  defp answerable?(state) do
    state["status"] == "playing" and not state["brief"] and is_nil(state["feedback"])
  end

  defp submit_pretest(state, step, value) do
    if Enum.any?(step.options, fn {letter, _} -> letter == value end) do
      state
      |> update_in(["pretest"], &Map.put(&1, step.id, value))
      |> Map.put("input", nil)
      |> advance()
    else
      state
    end
  end

  defp submit_choice(state, step, value) do
    if Enum.any?(step.options, fn {key, _} -> key == value end),
      do: resolve(state, step, value, value == step.answer),
      else: state
  end

  defp resolve(state, _step, "", _correct?), do: state

  defp resolve(state, step, answer, correct?) do
    hint? = state["hint"]
    streak = if correct?, do: state["streak"] + 1, else: 0
    gained = if correct?, do: max(step.points - hint_cost(step, hint?), 0) + streak_bonus(streak), else: 0
    lives = if step.lives? and not correct?, do: state["lives"] - 1, else: state["lives"]

    %{
      state
      | "points" => state["points"] + gained,
        "streak" => streak,
        "lives" => lives,
        "status" => if(lives <= 0, do: "game_over", else: "playing"),
        "feedback" => %{"correct" => correct?, "points" => gained, "answer" => answer},
        "log" => state["log"] ++ [%{"id" => step.id, "correct" => correct?, "points" => gained, "hint" => hint?}]
    }
  end

  defp hint_cost(step, true), do: step.hint_cost
  defp hint_cost(_step, false), do: 0

  defp streak_bonus(streak), do: @streak_bonus * min(streak - 1, @max_streak_steps)

  defp advance(state) do
    steps = steps()
    next = state["step"] + 1

    cond do
      next >= length(steps) ->
        %{state | "step" => next, "brief" => false, "status" => "finished"}

      Enum.at(steps, next).phase != Enum.at(steps, state["step"]).phase ->
        %{state | "step" => next, "brief" => true}

      true ->
        %{state | "step" => next}
    end
  end

  defp level(points, perfect?) do
    ratio = points / max_points()

    id =
      cond do
        perfect? -> "especialista-ram"
        ratio >= 0.7 -> "especialista-pga"
        ratio >= 0.4 -> "sentinela"
        true -> "aprendiz"
      end

    Enum.find(@levels, &(&1.id == id))
  end

  defp axis_percent(scored, log, axis) do
    items = Enum.filter(scored, &(&1.axis == axis))
    correct = Enum.count(items, &(get_in(log, [&1.id, "correct"]) == true))
    round(correct * 100 / max(length(items), 1))
  end

  defp pretest_score(state) do
    questions = Content.pretest()
    correct = Enum.count(questions, &(state["pretest"][&1.id] == &1.answer))
    %{correct: correct, total: length(questions)}
  end

  defp phase_results(scored, log) do
    for phase <- Enum.reject(@phases, &(&1.id == "pretest")) do
      items = Enum.filter(scored, &(&1.phase == phase.id))

      %{
        title: phase.title,
        correct: Enum.count(items, &(get_in(log, [&1.id, "correct"]) == true)),
        answered: Enum.count(items, &Map.has_key?(log, &1.id)),
        total: length(items)
      }
    end
  end

  defp review_items(scored, log) do
    for step <- scored, get_in(log, [step.id, "correct"]) != true do
      %{
        topic: step.topic,
        answered?: Map.has_key?(log, step.id),
        explanation: explanation(step)
      }
    end
  end

  defp explanation(%{kind: :text} = step), do: step.hint <> " " <> step.expected

  defp explanation(%{kind: kind} = step) when kind in [:choice, :certos] do
    {_key, text} = Enum.find(step.options, fn {key, _} -> key == step.answer end)
    step.wrong_feedback <> " Resposta correta: " <> text
  end

  # Aceita a resposta que contém, em cada grupo, ao menos um termo no início de uma palavra.
  defp correct_text?(text, %{keywords: groups}) do
    normalized = normalize(text)

    Enum.all?(groups, fn terms ->
      Enum.any?(terms, &Regex.match?(Regex.compile!("(?<![a-z0-9])" <> Regex.escape(&1)), normalized))
    end)
  end

  defp normalize(text) do
    text
    |> String.downcase()
    |> :unicode.characters_to_nfd_binary()
    |> String.replace(~r/\p{Mn}/u, "")
    |> String.replace(~r/[^a-z0-9]+/, " ")
  end
end
