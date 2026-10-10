defmodule AppWeb.User.UserLive.Index do
  use AppWeb, :live_view

  alias App.Users
  alias App.Accounts.User
  import App.Utils

  @impl true
  def mount(_params, _session, socket) do
    info_page = %{
			title: "Users",
			breadcrumb: [
        %{title: "Home", link: "/"},
        %{title: "Roteiros", link: ""}
      ]
		}
    {:ok, assign(socket, :users, Users.list_users_by_order()) |> assign(:info_page, info_page)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Editar")
    |> assign(:user, Users.get_user!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Novo")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listar")
    |> assign(:user, nil)
  end

  @impl true
  def handle_info({AppWeb.User.UserLive.FormComponent, {:saved, _user}}, socket) do
    {:noreply, assign(socket, :users, Users.list_users_by_order())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    user = Users.get_user!(id)
    {:ok, _} = Users.delete_user(user)

    {:noreply, assign(socket, :users, user)}
  end
end
