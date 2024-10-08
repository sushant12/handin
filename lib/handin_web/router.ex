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

  pipeline :check_archived_module do
    plug HandinWeb.Plugs.CheckArchivedModule
  end

  import Phoenix.LiveDashboard.Router

  if Application.compile_env(:handin, :dev_routes) do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope "/admin", HandinWeb.Admin, as: :admin do
    pipe_through [:browser, :require_authenticated_user, :authenticate_admin]

    live_dashboard "/live_dashboard", metrics: HandinWeb.Telemetry

    resources "/programming_languages", ProgrammingLanguageController

    resources "/users", UserController

    resources "/builds", BuildController

    resources "/assignments", AssignmentController

    resources "/assignments/:assignment_id/assignment_tests", AssignmentTestController

    resources "/assignment_submissions", AssignmentSubmissionController

    resources "/modules", ModuleController

    resources "/modules/:module_id/modules_users", ModulesUsersController
  end

  scope "/", HandinWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_lecturer_or_ta,
      on_mount: [
        {HandinWeb.UserAuth, :ensure_authenticated},
        {HandinWeb.Auth, :lecturer_or_ta}
      ] do
      live "/modules/new", ModulesLive.Index, :new
      live "/modules/archived", ArchivedModulesLive.Index, :index

      scope "/modules/:id" do
        pipe_through :check_archived_module

        live "/clone", ModulesLive.Index, :clone
        live "/archive", ModulesLive.Index, :archive
        live "/unarchive", ArchivedModulesLive.Index, :unarchive

        live "/edit", ModulesLive.Index, :edit
        live "/assignments/new", AssignmentLive.Index, :new

        scope "/assignments/:assignment_id" do
          live "/edit", AssignmentLive.Index, :edit
          live "/environment", AssignmentLive.Environment, :index
          live "/add_helper_files", AssignmentLive.Environment, :add_helper_files
          live "/add_solution_files", AssignmentLive.Environment, :add_solution_files

          live "/tests", AssignmentLive.Tests, :index
          live "/add_test", AssignmentLive.Show, :add_assignment_test
          live "/submissions", AssignmentLive.Submission, :index
          live "/settings", AssignmentLive.Settings, :index

          live "/settings/add_custom_assignment_date",
               AssignmentLive.Settings,
               :add_custom_assignment_date

          live "/settings/edit_custom_assignment_date/:custom_assignment_date_id",
               AssignmentLive.Settings,
               :edit_custom_assignment_date

          post "/download", SubmissionController, :download
        end

        live "/assignments/:assignment_id/:test_id/edit_test",
             AssignmentLive.Show,
             :edit_assignment_test

        live "/students/new", StudentsLive.Index, :new
        live "/students/bulk_add", StudentsLive.Index, :bulk_add

        live "/students/:user_id/show", StudentsLive.Show, :show
        live "/teaching_assistants/new", TeachingAssistantsLive.Index, :new
        live "/teaching_assistants/delete", TeachingAssistantsLive.Index, :delete
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
        pipe_through :check_archived_module

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
             AssignmentSubmissionsLive.Show,
             :show

        live "/students", StudentsLive.Index, :index
        live "/teaching_assistants", TeachingAssistantsLive.Index, :index
      end
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
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{HandinWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
