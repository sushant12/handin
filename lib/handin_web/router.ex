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
    # import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      # live_dashboard "/dashboard", metrics: HandinWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/admin", HandinWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_admin,
      on_mount: [{HandinWeb.UserAuth, :ensure_authenticated}, {HandinWeb.Auth, :admin}] do
      live "/universities", UniversityLive.Index, :index
      live "/universities/new", UniversityLive.Index, :new
      live "/universities/:id/edit", UniversityLive.Index, :edit

      live "/universities/:id", UniversityLive.Show, :show
      live "/universities/:id/show/edit", UniversityLive.Show, :edit

      live "/programming_languages", ProgrammingLanguageLive.Index, :index
      live "/programming_languages/new", ProgrammingLanguageLive.Index, :new
      live "/programming_languages/:id/edit", ProgrammingLanguageLive.Index, :edit

      live "/programming_languages/:id", ProgrammingLanguageLive.Show, :show
      live "/programming_languages/:id/show/edit", ProgrammingLanguageLive.Show, :edit

      live "/users", UserListLive.Index, :index
      live "/users/:user_id/edit", UserListLive.Index, :edit

      live "/builds", BuildLive.Index, :index
      live "/builds/:build_id/edit", BuildLive.Index, :edit
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

    live_session :require_authenticated_admin_or_lecturer,
      on_mount: [
        {HandinWeb.UserAuth, :ensure_authenticated},
        {HandinWeb.Auth, :admin_or_lecturer}
      ] do
      live "/modules/new", ModulesLive.Index, :new

      scope "/modules/:id" do
        live "/edit", ModulesLive.Index, :edit
        live "/assignments/new", AssignmentLive.Index, :new
        live "/assignments/:assignment_id/edit", AssignmentLive.Index, :edit

        scope "/assignments/:assignment_id" do
          live "/environment", AssignmentLive.Environment, :index
          live "/add_helper_files", AssignmentLive.Environment, :add_helper_files
          live "/add_solution_files", AssignmentLive.Environment, :add_solution_files

          live "/tests", AssignmentLive.Tests, :index
          live "/submissions", AssignmentLive.Submission, :index
          live "/settings", AssignmentLive.Settings, :index
        end

        live "/assignments/:assignment_id/add_test",
             AssignmentLive.Show,
             :add_assignment_test

        live "/assignments/:assignment_id/:test_id/edit_test",
             AssignmentLive.Show,
             :edit_assignment_test

        live "/members/new", MembersLive.Index, :new
      end
    end
  end

  scope "/", HandinWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{HandinWeb.UserAuth, :ensure_authenticated}] do
      live "/", DashboardLive.Index, :index
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/modules", ModulesLive.Index, :index

      scope "/modules/:id" do
        live "/assignments", AssignmentLive.Index, :index
        live "/grades", AssignmentLive.Grade, :index

        scope "/assignments/:assignment_id" do
          live "/details", AssignmentLive.Detail, :index
          live "/submit", AssignmentLive.Submit, :index
        end

        live "/assignments/:assignment_id/upload_submissions",
             AssignmentLive.Submit,
             :upload_submissions

        live "/assignments/:assignment_id/submission/:submission_id",
             AssignmentSubmissionLive.Show,
             :show

        live "/members", MembersLive.Index, :index
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
