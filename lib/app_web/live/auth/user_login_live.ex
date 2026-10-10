defmodule AppWeb.Auth.UserLoginLive do
  use AppWeb, :live_view

  def render(assigns) do
    ~H"""
    <.flash_group flash={@flash} id={"app-page-#{System.unique_integer([:positive]) |> Integer.to_string()}"} />
    <div class="mx-auto max-w-sm w-lg-400px w-300px">
      <image
        src={~p"/images/doris_atencao.png"}
        alt="Dóris"
        class="d-block mx-auto"
        style="width: 200px; margin-top: 50px; margin-bottom: 30px;"
      />
      <.header class="text-center">
        <%!-- RoteiroCare - Plataforma Digital de Educação em Gestão e descarte de Resíduos de Saúde --%>
        <:subtitle>
          Bem-vindo, para continuar faça o login.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/auth/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />
        <:actions>
          <.button phx-disable-with="Signing in..." class="w-full">
            Entrar <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>

      <div class="text-center mt-4">
        <p class="text-sm">
          Não tem uma conta?
          <.link navigate={~p"/auth/register"} class="font-semibold text-brand hover:underline">
        Registre-se aqui
          </.link>
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
