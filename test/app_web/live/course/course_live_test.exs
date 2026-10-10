defmodule AppWeb.Course.CourseLiveTest do
  use AppWeb.ConnCase

  import Phoenix.LiveViewTest
  import App.CoursesFixtures

  @create_attrs %{date: "2024-06-19T23:40:00", description: "some description", image: "some image", text: "some text", title: "some title", video: "some video"}
  @update_attrs %{date: "2024-06-20T23:40:00", description: "some updated description", image: "some updated image", text: "some updated text", title: "some updated title", video: "some updated video"}
  @invalid_attrs %{date: nil, description: nil, image: nil, text: nil, title: nil, video: nil}

  defp create_course(_) do
    course = course_fixture()
    %{course: course}
  end

  describe "Index" do
    setup [:create_course]

    test "lists all courses", %{conn: conn, course: course} do
      {:ok, _index_live, html} = live(conn, ~p"/course/courses")

      assert html =~ "Listing Courses"
      assert html =~ course.description
    end

    test "saves new course", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/course/courses")

      assert index_live |> element("a", "New Course") |> render_click() =~
               "New Course"

      assert_patch(index_live, ~p"/course/courses/new")

      assert index_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#course-form", course: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/course/courses")

      html = render(index_live)
      assert html =~ "Course created successfully"
      assert html =~ "some description"
    end

    test "updates course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/course/courses")

      assert index_live |> element("#courses-#{course.id} a", "Edit") |> render_click() =~
               "Edit Course"

      assert_patch(index_live, ~p"/course/courses/#{course}/edit")

      assert index_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#course-form", course: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/course/courses")

      html = render(index_live)
      assert html =~ "Course updated successfully"
      assert html =~ "some updated description"
    end

    test "deletes course in listing", %{conn: conn, course: course} do
      {:ok, index_live, _html} = live(conn, ~p"/course/courses")

      assert index_live |> element("#courses-#{course.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#courses-#{course.id}")
    end
  end

  describe "Show" do
    setup [:create_course]

    test "displays course", %{conn: conn, course: course} do
      {:ok, _show_live, html} = live(conn, ~p"/course/courses/#{course}")

      assert html =~ "Show Course"
      assert html =~ course.description
    end

    test "updates course within modal", %{conn: conn, course: course} do
      {:ok, show_live, _html} = live(conn, ~p"/course/courses/#{course}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Course"

      assert_patch(show_live, ~p"/course/courses/#{course}/show/edit")

      assert show_live
             |> form("#course-form", course: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#course-form", course: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/course/courses/#{course}")

      html = render(show_live)
      assert html =~ "Course updated successfully"
      assert html =~ "some updated description"
    end
  end
end
