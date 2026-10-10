defmodule AppWeb.User.UserLive.FormComponent do
  use AppWeb, :live_component

  alias App.Users

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Formulário de cadastro</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user-form"
        phx-target={@myself}
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Nome" required autocomplete="off" />
        <.input field={@form[:email]} type="email" label="Email" required autocomplete="off" />
        <.input field={@form[:superadmin]} type="checkbox" label="Superadmin" />
        <:actions>
          <.button phx-disable-with="Salvando...">Salvar</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Users.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Users.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Users.update_user(socket.assigns.user, user_params) do
      {:ok, user} ->
        {:noreply, socket |> put_flash(:info, "Usuário atualizado com sucesso.")}
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, changeset)}
    end
  end

  defp assign_form(socket, changeset) do
    assign(socket, :form, changeset)
  end
end
