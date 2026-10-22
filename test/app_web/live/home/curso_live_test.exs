defmodule AppWeb.CursoLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.CoursesFixtures

  alias App.Courses

  setup :register_and_log_in_user

  setup do
    m1 = course_fixture(%{title: "Resistência Antimicrobiana (RAM)", position: 1})
    m2 = course_fixture(%{title: "Antimicrobianos na prática", position: 2})
    %{m1: m1, m2: m2}
  end

  test "shows the course aside with all sections and the first one active", %{conn: conn, m1: m1} do
    {:ok, view, html} = live(conn, ~p"/cursos/#{m1.id}")

    assert html =~ "Curso 1"
    assert html =~ "Resistência Antimicrobiana (RAM)"
    assert has_element?(view, "#curso-section-introducao")
    assert has_element?(view, "#curso-section-papel-da-enfermagem")
    assert has_element?(view, "#curso-section-title", "Introdução")
    assert has_element?(view, "li.active #curso-section-introducao")
    assert has_element?(view, "img[src='/images/cursos/curso_1/figura_1.png']")
    assert has_element?(view, "#curso-next", "Próxima Sessão")
    refute has_element?(view, "#curso-prev")
  end

  test "navigates between sections", %{conn: conn, m1: m1} do
    {:ok, view, _html} = live(conn, ~p"/cursos/#{m1.id}")

    view |> element("#curso-next") |> render_click()
    assert_patch(view, ~p"/cursos/#{m1.id}?secao=conceito-de-ram")
    assert has_element?(view, "#curso-section-title", "Conceito de Resistência Antimicrobiana")
    assert has_element?(view, "#curso-prev")

    view |> element("#curso-section-superbacterias") |> render_click()
    assert has_element?(view, "li.active #curso-section-superbacterias")
  end

  test "keeps the self-reflection answer while navigating", %{conn: conn, m1: m1} do
    {:ok, view, _html} = live(conn, ~p"/cursos/#{m1.id}?secao=mecanismos-de-resistencia")

    view
    |> form("#reflection-mecanismo-uti", %{"answer" => "Biofilme"})
    |> render_change()

    view |> element("#curso-next") |> render_click()
    view |> element("#curso-prev") |> render_click()

    assert render(view) =~ "Biofilme"
  end

  test "completing the course from the last section unlocks the next module", %{
    conn: conn,
    user: user,
    m1: m1,
    m2: m2
  } do
    {:ok, view, _html} = live(conn, ~p"/cursos/#{m1.id}?secao=avaliacao")

    refute has_element?(view, "#curso-next")
    assert has_element?(view, "#curso-section-title", "Avaliação")
    refute has_element?(view, "#curso-complete")

    answer_all(view, ~w(c b c a d))

    assert {:error, {:redirect, %{to: "/"}}} = view |> element("#curso-complete") |> render_click()
    assert MapSet.member?(Courses.completed_course_ids(user.id), m1.id)
    assert Courses.course_unlocked?(user, m2)
  end

  test "the course cannot be completed without 100% on the evaluation", %{
    conn: conn,
    user: user,
    m1: m1
  } do
    {:ok, view, _html} = live(conn, ~p"/cursos/#{m1.id}?secao=avaliacao")
    answer_all(view, ~w(a b c a d))

    refute has_element?(view, "#curso-complete")

    assert render_click(view, "complete_module", %{}) =~ "Acerte todas as questões"
    refute MapSet.member?(Courses.completed_course_ids(user.id), m1.id)
  end

  defp answer(view, option) do
    view |> form("#quiz-avaliacao-form", %{"option" => option}) |> render_change()
    view |> form("#quiz-avaliacao-form", %{"option" => option}) |> render_submit()
  end

  defp answer_all(view, options) do
    for option <- options do
      answer(view, option)
      if has_element?(view, "#quiz-next"), do: view |> element("#quiz-next") |> render_click()
    end
  end

  test "references is section 11 and the evaluation is section 12", %{conn: conn, m1: m1} do
    {:ok, view, _html} = live(conn, ~p"/cursos/#{m1.id}?secao=referencias")

    assert has_element?(view, "#curso-section-referencias .curso-aside-number", "11")
    assert has_element?(view, "#curso-section-avaliacao .curso-aside-number", "12")
    assert has_element?(view, "#curso-next", "Próxima Sessão")
  end

  describe "evaluation" do
    setup %{conn: conn, m1: m1} do
      {:ok, view, _html} = live(conn, ~p"/cursos/#{m1.id}?secao=avaliacao")
      %{view: view}
    end

    test "starts on the first question without feedback", %{view: view} do
      assert has_element?(view, "#quiz-question", "A resistência antimicrobiana ocorre principalmente devido:")
      assert has_element?(view, "#quiz-validate[disabled]")
      refute has_element?(view, "#quiz-feedback")
      refute has_element?(view, "#quiz-next")
    end

    test "validating reveals the correct answer even when wrong", %{view: view} do
      answer(view, "a")

      assert has_element?(view, "#quiz-feedback", "Resposta correta: C")
      assert has_element?(view, "#quiz-feedback", "Você respondeu A.")
      assert has_element?(view, "#quiz-next", "Próxima Questão")
      refute has_element?(view, "#quiz-validate")
    end

    test "locks the chosen answer after validation", %{view: view} do
      answer(view, "c")
      render_change(view, "quiz_select", %{"key" => "avaliacao", "option" => "a"})

      assert has_element?(view, "#quiz-feedback", "Você acertou!")
      assert has_element?(view, "input[value='c'][checked]")
    end

    test "100% shows the congratulations and closing message", %{view: view} do
      answer_all(view, ~w(c b c a d))

      assert has_element?(view, "#quiz-closing", "Você acertou 5 de 5 questões.")
      assert has_element?(view, "#quiz-closing", "No próximo módulo")
      refute has_element?(view, "#quiz-retry")
      refute has_element?(view, "#quiz-next")
    end

    test "with errors shows the score and lets the student retry", %{view: view} do
      answer_all(view, ~w(a b c a d))

      assert has_element?(view, "#quiz-retry", "Você acertou 4 de 5 questões.")
      refute has_element?(view, "#quiz-closing")

      view |> element("#quiz-reset") |> render_click()

      assert has_element?(view, "#quiz-question", "A resistência antimicrobiana ocorre")
      refute has_element?(view, "#quiz-feedback")
      refute has_element?(view, "#quiz-retry")

      answer_all(view, ~w(c b c a d))
      assert has_element?(view, "#quiz-closing")
      assert has_element?(view, "#curso-complete")
    end

    test "does not show the closing message before the last question", %{view: view} do
      answer(view, "c")
      refute has_element?(view, "#quiz-closing")
    end
  end

  test "redirects locked modules and modules without content", %{conn: conn, m2: m2} do
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/cursos/#{m2.id}")
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/cursos/0")
  end

  test "start button of module 1 points to the course page", %{conn: conn, m1: m1} do
    {:ok, view, _html} = live(conn, ~p"/")
    assert has_element?(view, "a#module-start-#{m1.id}[href='/cursos/#{m1.id}']")
  end
end
