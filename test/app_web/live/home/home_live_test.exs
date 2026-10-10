defmodule AppWeb.HomeLiveTest do
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

  test "lists modules from the database with only the first one unlocked", %{conn: conn, m1: m1, m2: m2} do
    {:ok, view, html} = live(conn, ~p"/")

    assert html =~ "Módulos"
    assert html =~ "Resistência Antimicrobiana (RAM)"
    assert html =~ "Requisitos: Módulo 1"

    assert has_element?(view, "a#module-start-#{m1.id}")
    assert has_element?(view, "button#module-start-#{m2.id}[disabled]")
    assert has_element?(view, "a#module-details-#{m2.id}")
  end

  test "details page shows the module info", %{conn: conn, m1: m1} do
    {:ok, view, html} = live(conn, ~p"/modulos/#{m1.id}")

    assert html =~ "Módulo 1"
    assert html =~ m1.description
    assert has_element?(view, "a#module-start")
  end

  test "details page of a locked module has Iniciar disabled", %{conn: conn, m2: m2} do
    {:ok, view, _html} = live(conn, ~p"/modulos/#{m2.id}")
    assert has_element?(view, "button#module-start[disabled]")
  end

  test "details page redirects for unknown modules", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/modulos/0")
  end

  test "content page of a locked module redirects to home", %{conn: conn, m2: m2} do
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/show/#{m2.id}")
  end

  test "finishing module 1 unlocks module 2", %{conn: conn, user: user, m1: m1, m2: m2} do
    {:ok, view, _html} = live(conn, ~p"/show/#{m1.id}")

    assert {:error, {:redirect, %{to: "/"}}} =
             view |> element("#complete-module-btn") |> render_click()

    assert MapSet.member?(Courses.completed_course_ids(user.id), m1.id)

    {:ok, home, _html} = live(conn, ~p"/")
    assert has_element?(home, "a#module-start-#{m2.id}")

    assert {:ok, _view, _html} = live(conn, ~p"/show/#{m2.id}")
  end
end
