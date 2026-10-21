defmodule AppWeb.Router do
  use AppWeb, :router

  import AppWeb.Auth.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :sistem do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root2}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :sistem_sem_aside do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AppWeb.Layouts, :root3}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AppWeb do
    pipe_through [:browser]

    live "/landing", LandingLive, :landing
  end

  scope "/", AppWeb do
    pipe_through [:sistem_sem_aside, :require_authenticated_user]

    live "/", HomeLive, :index
    live "/modulos/:id", ModuloLive, :show
    live "/cursos/:id", CursoLive, :show
  end

  scope "/", AppWeb do
    pipe_through [:sistem, :require_authenticated_user]
    live "/protocolos", ProtocoloLive, :index
    live "/show/:id", ShowLive, :show
  end

  scope "/course", AppWeb.Course, as: :course do
    pipe_through [:sistem, :require_authenticated_user]

    live "/courses", CourseLive.Index, :index
    live "/courses/new", CourseLive.Index, :new
    live "/courses/:id/edit", CourseLive.Index, :edit

    live "/courses/:id", CourseLive.Show, :show
    live "/courses/:id/show/edit", CourseLive.Show, :edit
  end

  scope "/user", AppWeb.User, as: :course do
    pipe_through [:sistem, :require_authenticated_user]

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit
  end

  scope "/auth", AppWeb.Auth, as: :auth do
    pipe_through [:sistem, :require_authenticated_user, :is_super_admin]

    live_session :require_authenticated_user,
      on_mount: [{AppWeb.Auth.UserAuth, :ensure_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
    end
  end



  ## Authentication routes

  # scope "/guisabe", AppWeb.Auth, as: :auth do
  #   pipe_through [:browser]

  #   live "/users/register", UserRegistrationLive, :new
  # end

  scope "/auth", AppWeb.Auth, as: :auth do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{AppWeb.Auth.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
      live "/register", UserRegistrationLive, :new
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/auth", AppWeb.Auth, as: :auth do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{AppWeb.Auth.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
