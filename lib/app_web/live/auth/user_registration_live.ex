defmodule AppWeb.Auth.UserRegistrationLive do
  use AppWeb, :live_view

  alias App.Accounts
  alias App.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="d-flex flex-column flex-row-fluid" id="kt_wrapper">
      <div class="post d-flex flex-column-fluid" id="kt_post">
        <div id="kt_content_container" class="container-xxl w-lg-400px w-300px">
          <image
            src={~p"/images/doris_atencao.png"}
            alt="Dóris"
            class="d-block mx-auto"
            style="width: 200px; margin-top: 50px; margin-bottom: 30px;"
          />
          <div class="card-header border-0 pt-6">
            <.header class="text-center">
              Registrar um novo usuário
            </.header>

            <.simple_form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              phx-trigger-action={@trigger_submit}
              method="post"
            >
              <.error :if={@check_errors}>
                Oops. Alguma coisa deu errado!
              </.error>
              <.input field={@form[:name]} type="text" label="Name" required autocomplete="false" />
              <.input field={@form[:email]} type="email" label="Email" required autocomplete="false" />
              <.input
                field={@form[:password]}
                type="password"
                label="Password"
                required
                autocomplete="false"
              />
                <.input
                :if={@current_user && @current_user.superadmin}
                field={@form[:superadmin]}
                type="checkbox"
                label="Superadmin"
                />

              <:actions>
                <.button phx-disable-with="Creating account..." class="w-full">Cadastrar</.button>
              </:actions>
            </.simple_form>
            <div :if={!@current_user} class="text-center mt-4">
              <p class="text-sm">
              Já tem uma conta?
              <.link navigate={~p"/auth/users/log_in"} class="font-semibold text-brand hover:underline">
                Faça login aqui
              </.link>
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        socket =
          socket
          |> put_flash(:info, "Conta criada. Faça login para continuar.")
          |> redirect(to: ~p"/auth/users/log_in")

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
