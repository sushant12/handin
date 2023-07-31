defmodule HandinWeb.Router do
  use HandinWeb, :router

  import HandinWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {HandinWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug HandinWeb.Plugs.CheckAdmin
  end

  # Other scopes may use custom stacks.
  # scope "/api", HandinWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:handin, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HandinWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/admin", HandinWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user, :admin]

    live_session :require_authenticated_admin,
      on_mount: [{HandinWeb.UserAuth, :ensure_authenticated}] do
      live "/universities", UniversityLive.Index, :index
      live "/universities/new", UniversityLive.Index, :new
      live "/universities/:id/edit", UniversityLive.Index, :edit

      live "/universities/:id", UniversityLive.Show, :show
      live "/universities/:id/show/edit", UniversityLive.Show, :edit
    end
  end

  scope "/", HandinWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{HandinWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", HandinWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HandinWeb.UserAuth, :ensure_authenticated}] do
      live "/", DashboardLive.Index, :index
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/modules", ModulesLive.Index, :index
      live "/modules/new", ModulesLive.Index, :new
      live "/modules/:id/edit", ModulesLive.Index, :edit

      live "/modules/:id", ModulesLive.Show, :show

      scope "/modules/:id" do
        live "/assignments", AssignmentLive.Index, :index
        live "/assignments/new", AssignmentLive.Index, :new
        live "/assignments/:id/edit", AssignmentLive.Index, :edit

        live "/assignments/:id", AssignmentLive.Show, :show
        live "/assignments/:id/show/edit", AssignmentLive.Show, :edit
      end
    end
  end

  scope "/", HandinWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{HandinWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
