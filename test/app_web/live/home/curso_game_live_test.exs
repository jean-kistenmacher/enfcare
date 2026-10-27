defmodule AppWeb.CursoGameLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.CoursesFixtures

  alias App.CourseGame
  alias App.Courses

  @path "?secao=atividade-gamificada"
  @key "atividade-gamificada"
  @form "#game-atividade-gamificada-form"

  setup :register_and_log_in_user

  setup %{user: user} do
    m1 = course_fixture(%{title: "Resistência Antimicrobiana (RAM)", position: 1})
    m2 = course_fixture(%{title: "Antimicrobianos na prática", position: 2})
    {:ok, _} = Courses.complete_course(user, m1)
    %{m2: m2}
  end

  defp right_params(%{kind: :text} = step), do: %{"answer" => step.expected}
  defp right_params(step), do: %{"option" => step.answer}

  defp wrong_params(%{kind: :text}), do: %{"answer" => "não sei"}

  defp wrong_params(step) do
    {key, _} = Enum.find(step.options, fn {key, _} -> key != step.answer end)
    %{"option" => key}
  end

  defp play_step(view, step, wrong?) do
    if has_element?(view, "#game-start"), do: view |> element("#game-start") |> render_click()

    params = if wrong?.(step), do: wrong_params(step), else: right_params(step)
    view |> form(@form, params) |> render_change()
    view |> form(@form, params) |> render_submit()

    if has_element?(view, "#game-continue"), do: view |> element("#game-continue") |> render_click()
  end

  defp play(view, wrong? \\ fn _ -> false end, count \\ :all) do
    steps = CourseGame.steps()
    steps = if count == :all, do: steps, else: Enum.take(steps, count)

    Enum.each(steps, fn step ->
      unless has_element?(view, "#game-summary"), do: play_step(view, step, wrong?)
    end)
  end

  test "the game is the 12th section and starts with the rules", %{conn: conn, m2: m2} do
    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")

    assert has_element?(view, "li.active #curso-section-atividade-gamificada .curso-aside-number", "12")
    assert has_element?(view, "#curso-section-title", "Atividade Gamificada")
    assert has_element?(view, "#game-brief", "Regras do jogo")
    assert has_element?(view, "#game-brief", "Pré-teste")
    refute has_element?(view, "#curso-next")
    refute has_element?(view, "#curso-complete")
  end

  test "the pre-test gives no feedback and moves straight to the next question", %{conn: conn, m2: m2} do
    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")

    view |> element("#game-start") |> render_click()
    assert has_element?(view, "#game-prompt", "Os antimicrobianos são classificados")
    refute has_element?(view, "#game-hint")

    view |> form(@form, %{"option" => "a"}) |> render_change()
    view |> form(@form, %{"option" => "a"}) |> render_submit()

    refute has_element?(view, "#game-feedback")
    assert has_element?(view, "#game-prompt", "Biologicamente")
  end

  test "phase 1 shows the hint, charges points and gives feedback on a miss", %{conn: conn, m2: m2} do
    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")

    play(view, fn _ -> false end, 10)
    assert has_element?(view, "#game-brief", "Fase 1")
    view |> element("#game-start") |> render_click()

    view |> element("#game-hint") |> render_click()
    assert has_element?(view, "#game-hint-text", "esteriliza o sangue")
    refute has_element?(view, "#game-hint")

    view |> form(@form, %{"answer" => "coletar antes"}) |> render_submit()
    assert has_element?(view, "#game-feedback", "Você acertou!")
    assert has_element?(view, "#game-feedback", "+6 pontos")
    assert has_element?(view, "#game-points", "6")

    view |> element("#game-continue") |> render_click()
    view |> form(@form, %{"answer" => "não sei"}) |> render_submit()
    assert has_element?(view, "#game-feedback", "Resposta incorreta")
    assert has_element?(view, "#game-feedback", "Resposta de referência")
    assert has_element?(view, "#game-lives", "♥")
  end

  test "a perfect run shows the reflective summary and allows completing the module", %{
    conn: conn,
    user: user,
    m2: m2
  } do
    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")
    refute has_element?(view, "#curso-complete")

    assert render_click(view, "complete_module", %{}) =~ "Finalize a atividade gamificada"
    refute MapSet.member?(Courses.completed_course_ids(user.id), m2.id)

    play(view)

    assert has_element?(view, "#game-level", "Especialista em RAM")
    assert has_element?(view, "#game-final-points", "340 de 340")
    assert has_element?(view, "#game-effectiveness", "100%")
    assert has_element?(view, "#game-safety", "100%")
    assert has_element?(view, "#game-pretest", "10 de 10")
    assert has_element?(view, "#game-strengths")
    refute has_element?(view, "#game-review")

    attempt = Courses.get_game_attempt(user, m2, @key)
    assert %{status: "finished", points: 340, level: "especialista-ram"} = attempt
    assert attempt.effectiveness == 100 and attempt.safety == 100
    assert attempt.finished_at

    assert {:error, {:redirect, %{to: "/"}}} = view |> element("#curso-complete") |> render_click()
    assert MapSet.member?(Courses.completed_course_ids(user.id), m2.id)
  end

  test "losing all lives ends the game for good, with the review of the gaps", %{
    conn: conn,
    user: user,
    m2: m2
  } do
    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")

    play(view, &(&1.phase in ["f2", "f3"]))

    assert has_element?(view, "#game-summary", "Suas vidas acabaram")
    assert has_element?(view, "#game-review", "não alcançado")
    refute has_element?(view, "#game-level", "Especialista em RAM")
    assert has_element?(view, "#curso-complete")
    assert %{status: "game_over"} = Courses.get_game_attempt(user, m2, @key)

    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")
    assert has_element?(view, "#game-summary")
    refute has_element?(view, "#game-start")
  end

  test "the progress is saved and restored when the page is reloaded", %{conn: conn, m2: m2} do
    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")

    play(view, fn _ -> false end, 10)
    view |> element("#game-start") |> render_click()
    view |> form(@form, %{"answer" => "não sei"}) |> render_submit()

    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")
    assert has_element?(view, "#game-feedback", "Resposta incorreta")

    view |> element("#game-continue") |> render_click()
    assert has_element?(view, "#game-prompt", "A prescrição indica um antimicrobiano")
  end

  test "phase 3 shows the prescription, the nurse check and the 13 certos", %{conn: conn, m2: m2} do
    {:ok, view, _html} = live(conn, "/cursos/#{m2.id}#{@path}")

    play(view, fn _ -> false end, 18)
    view |> element("#game-start") |> render_click()

    assert has_element?(view, ".curso-game-doc h3", "Prescrição médica")
    assert has_element?(view, ".curso-game-doc h3", "Checagem de enfermagem")
    assert has_element?(view, ".curso-game-doc", "Meropenem 1 g")
    assert has_element?(view, "#game-prompt", "Qual dos 13 certos foi violado?")
    assert render(view) |> String.split("name=\"option\"") |> length() == 14

    view |> form(@form, %{"option" => "paciente"}) |> render_submit()
    assert has_element?(view, "#game-feedback", "Você perdeu uma vida.")
    assert has_element?(view, "#game-feedback", "Horário certo")
  end
end
