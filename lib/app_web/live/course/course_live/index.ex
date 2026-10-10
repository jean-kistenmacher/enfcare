defmodule AppWeb.Course.CourseLive.Index do
  use AppWeb, :live_view

  alias App.Courses
  alias App.Courses.Course
  import App.Utils

  @impl true
  def mount(_params, _session, socket) do
    info_page = %{
			title: "Roteiros",
			breadcrumb: [
        %{title: "Home", link: "/"},
        %{title: "Roteiros", link: ""}
      ]
		}
    {:ok, assign(socket, :courses, Courses.list_courses_by_order()) |> assign(:info_page, info_page)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar")
    |> assign(:course, Courses.get_course!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo")
    |> assign(:course, %Course{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listar")
    |> assign(:course, nil)
  end

  @impl true
  def handle_info({AppWeb.Course.CourseLive.FormComponent, {:saved, _course}}, socket) do
    {:noreply, assign(socket, :courses, Courses.list_courses_by_order())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    course = Courses.get_course!(id)
    {:ok, _} = Courses.delete_course(course)

    {:noreply, assign(socket, :courses, course)}
  end
end
