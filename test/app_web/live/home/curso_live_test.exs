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
    {:ok, view, _html} = live(conn, ~p"/cursos/#{m1.id}?secao=referencias")

    refute has_element?(view, "#curso-next")
    assert has_element?(view, "#curso-section-title", "Referências")

    assert {:error, {:redirect, %{to: "/"}}} = view |> element("#curso-complete") |> render_click()
    assert MapSet.member?(Courses.completed_course_ids(user.id), m1.id)
    assert Courses.course_unlocked?(user, m2)
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
