defmodule Handin.Modules do
  @moduledoc """
  The Modules context.
  """

  import Ecto.Query, warn: false
  alias Handin.Assignments.CustomAssignmentDate
  alias Handin.Repo
  alias Handin.Accounts
  alias Handin.Accounts.User
  alias Handin.Modules
  alias Handin.Modules.ModulesInvitations
  alias Handin.Modules.Module
  alias Handin.Modules.ModulesUsers
  alias Ecto.Multi
  alias Handin.Accounts.UserNotifier

  defmodule CloneModuleParams do
    defstruct [:module_id, :user_id, :timezone]

    @type t :: %__MODULE__{
            module_id: Ecto.UUID.t(),
            user_id: Ecto.UUID.t(),
            timezone: String.t()
          }
  end

  defmodule AddUserToModuleParams do
    defstruct [:module, :university_id, :emails]

    @type t :: %__MODULE__{
            module: Module.t(),
            university_id: Ecto.UUID.t(),
            emails: list(String.t())
          }
  end

  defmodule ModuleUsersParams do
    defstruct [:module_id, :user_id, :role]
    @type role :: :student | :admin | :lecturer | :teaching_assistant
    @type t :: %__MODULE__{
            module_id: Ecto.UUID.t(),
            user_id: Ecto.UUID.t(),
            role: role()
          }
  end

  @type archive_filter :: :all | :archived | :unarchived

  @spec get_students(module_id :: Ecto.UUID.t()) :: list(User.t())
  def get_students(module_id) do
    from(mu in ModulesUsers,
      where: mu.module_id == ^module_id and mu.role == :student,
      join: u in assoc(mu, :user),
      order_by: [asc: u.email],
      select: u
    )
    |> Repo.all()
  end

  def list_modules_invitations_for_module(id) do
    ModulesInvitations
    |> where([mi], mi.module_id == ^id)
    |> Repo.all()
  end

  def get_pending_students(module_id) do
    list_modules_invitations_for_module(module_id)
    |> Enum.map(&%User{id: &1.id, email: &1.email})
  end

  def get_students_without_custom_assignment_date(module_id, assignment_id) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == :student)
    |> join(:left, [m, u], cad in assoc(u, :custom_assignment_dates),
      on: cad.user_id == u.id and cad.assignment_id == ^assignment_id
    )
    |> where([m, u, cad], is_nil(cad.id))
    |> select([m, u], u)
    |> Repo.all()
  end

  @spec get_students_count(module_id :: Ecto.UUID) :: integer() | nil
  def get_students_count(module_id) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], u in assoc(m, :users), on: u.role == :student)
    |> select([m, u], count(u.id))
    |> Repo.one()
  end

  def get_assignments_count(module_id, user) do
    Module
    |> where([m], m.id == ^module_id)
    |> join(:inner, [m], a in assoc(m, :assignments), on: a.module_id == ^module_id)
    |> maybe_filter_by_released_assignment(user)
    |> select([m, a], count(a.id))
    |> Repo.one()
  end

  @spec clone_module(CloneModuleParams.t()) :: {:ok, any()} | {:error, String.t()}
  def clone_module(%CloneModuleParams{module_id: module_id, user_id: user_id, timezone: timezone}) do
    Multi.new()
    |> Multi.one(:original_module, fn _ ->
      query_module_with_associations(module_id)
    end)
    |> Multi.run(:cloned_module, fn _, %{original_module: original_module} ->
      create_cloned_module(original_module, user_id)
    end)
    |> Multi.merge(fn %{original_module: original_module, cloned_module: cloned_module} ->
      clone_assignments(original_module, cloned_module, timezone)
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{cloned_module: cloned_module}} -> {:ok, cloned_module}
      {:error, _} -> {:error, "Failed to clone module"}
    end
  end

  defp query_module_with_associations(module_id) do
    from(m in Module,
      where: m.id == ^module_id,
      left_join: a in assoc(m, :assignments),
      left_join: at in assoc(a, :assignment_tests),
      left_join: sf in assoc(a, :support_files),
      left_join: solf in assoc(a, :solution_files),
      preload: [assignments: {a, assignment_tests: at, support_files: sf, solution_files: solf}]
    )
  end

  defp create_cloned_module(original_module, user_id) do
    Modules.create_module(
      %{
        name: original_module.name,
        code: original_module.code,
        term: original_module.term <> " (copy)"
      },
      user_id
    )
  end

  defp clone_assignments(original_module, cloned_module, timezone) do
    Enum.reduce(original_module.assignments, Multi.new(), fn assignment, multi ->
      multi
      |> clone_assignment(assignment, cloned_module.id, timezone)
      |> clone_assignment_tests(assignment)
      |> clone_support_files(assignment)
      |> clone_solution_files(assignment)
    end)
  end

  defp clone_assignment(multi, assignment, cloned_module_id, timezone) do
    Multi.insert(multi, {:cloned_assignment, assignment.id}, fn _ ->
      Handin.Assignments.Assignment.changeset(%Handin.Assignments.Assignment{}, %{
        "name" => assignment.name,
        "start_date" => DateTime.utc_now() |> DateTime.add(7, :day),
        "due_date" => DateTime.utc_now() |> DateTime.add(14, :day),
        "run_script" => assignment.run_script,
        "enable_max_attempts" => assignment.enable_max_attempts,
        "max_attempts" => assignment.max_attempts,
        "enable_total_marks" => assignment.enable_total_marks,
        "total_marks" => assignment.total_marks,
        "enable_cutoff_date" => assignment.enable_cutoff_date,
        "cutoff_date" => DateTime.utc_now() |> DateTime.add(10, :day),
        "enable_penalty_per_day" => assignment.enable_penalty_per_day,
        "penalty_per_day" => assignment.penalty_per_day,
        "enable_attempt_marks" => assignment.enable_attempt_marks,
        "attempt_marks" => assignment.attempt_marks,
        "enable_test_output" => assignment.enable_test_output,
        "module_id" => cloned_module_id,
        "programming_language_id" => assignment.programming_language_id,
        "timezone" => timezone
      })
    end)
  end

  defp clone_assignment_tests(multi, assignment) do
    assignment_id = assignment.id

    Enum.reduce(assignment.assignment_tests, multi, fn assignment_test, multi ->
      Multi.insert(multi, {:cloned_assignment_test, assignment_test.id}, fn %{
                                                                              {:cloned_assignment,
                                                                               ^assignment_id} =>
                                                                                cloned_assignment
                                                                            } ->
        Handin.Assignments.AssignmentTest.changeset(
          %Handin.Assignments.AssignmentTest{},
          %{
            "name" => assignment_test.name,
            "points_on_pass" => assignment_test.points_on_pass,
            "points_on_fail" => assignment_test.points_on_fail,
            "command" => assignment_test.command,
            "expected_output_type" => assignment_test.expected_output_type,
            "expected_output_text" => assignment_test.expected_output_text,
            "expected_output_file" => assignment_test.expected_output_file,
            "expected_output_file_content" => assignment_test.expected_output_file_content,
            "ttl" => assignment_test.ttl,
            "enable_custom_test" => assignment_test.enable_custom_test,
            "custom_test" => assignment_test.custom_test,
            "assignment_id" => cloned_assignment.id
          }
        )
      end)
    end)
  end

  defp clone_support_files(multi, assignment) do
    assignment_id = assignment.id

    Enum.reduce(assignment.support_files, multi, fn support_file, multi ->
      support_file_id = support_file.id

      multi
      |> Multi.insert({:cloned_support_file, support_file.id}, fn %{
                                                                    {:cloned_assignment,
                                                                     ^assignment_id} =>
                                                                      cloned_assignment
                                                                  } ->
        Handin.Assignments.SupportFile.clone_changeset(
          %Handin.Assignments.SupportFile{},
          %{
            "file" => %{
              "file_name" => support_file.file.file_name,
              "updated_at" => NaiveDateTime.utc_now()
            },
            "assignment_id" => cloned_assignment.id
          }
        )
      end)
      |> Multi.run({:clone_s3_file, support_file.file}, fn _,
                                                           %{
                                                             {:cloned_support_file,
                                                              ^support_file_id} =>
                                                               cloned_support_file
                                                           } ->
        clone_s3_file(support_file, cloned_support_file)
      end)
    end)
  end

  defp clone_solution_files(multi, assignment) do
    Enum.reduce(assignment.solution_files, multi, fn solution_file, multi ->
      assignment_id = assignment.id
      solution_file_id = solution_file.id

      multi
      |> Multi.insert({:cloned_solution_file, solution_file.id}, fn %{
                                                                      {:cloned_assignment,
                                                                       ^assignment_id} =>
                                                                        cloned_assignment
                                                                    } ->
        Handin.Assignments.SolutionFile.clone_changeset(
          %Handin.Assignments.SolutionFile{},
          %{
            "file" => %{
              "file_name" => solution_file.file.file_name,
              "updated_at" => NaiveDateTime.utc_now()
            },
            "assignment_id" => cloned_assignment.id
          }
        )
      end)
      |> Multi.run({:clone_s3_file, solution_file.file}, fn _,
                                                            %{
                                                              {:cloned_solution_file,
                                                               ^solution_file_id} =>
                                                                cloned_solution_file
                                                            } ->
        clone_s3_file(solution_file, cloned_solution_file)
      end)
    end)
  end

  defp clone_s3_file(original_file, cloned_file) do
    case ExAws.S3.put_object_copy(
           "handin-dev",
           "/uploads/assignment/#{cloned_file.id}/#{cloned_file.file.file_name}",
           "handin-dev",
           "/uploads/assignment/#{original_file.id}/#{original_file.file.file_name}"
         )
         |> ExAws.request() do
      {:ok, _} -> {:ok, cloned_file}
      {:error, _} -> {:error, "Failed to clone file"}
    end
  end

  @spec list_module(User.t(), archive_filter()) :: list(Module.t())
  def list_module(user, archive_filter \\ :unarchived) do
    Module
    |> order_by([m], asc: m.inserted_at)
    |> filter_by_archive_status(archive_filter)
    |> maybe_filter_by_role(user.id, user.role)
    |> Repo.all()
  end

  defp filter_by_archive_status(query, :all), do: query
  defp filter_by_archive_status(query, :archived), do: where(query, [m], m.archived == true)
  defp filter_by_archive_status(query, :unarchived), do: where(query, [m], m.archived == false)

  defp maybe_filter_by_role(query, _user_id, :admin) do
    query
  end

  defp maybe_filter_by_role(query, user_id, role) when role in [:lecturer, :student] do
    query
    |> join(:inner, [m], mu in Handin.Modules.ModulesUsers, on: mu.user_id == ^user_id)
  end

  def get_module!(id),
    do: Repo.get(Module, id) |> Repo.preload(assignments: [:programming_language])

  @spec archive_module(Module.t()) :: {:ok, Module.t()} | {:error, String.t()}
  def archive_module(%Module{} = module) do
    module
    |> Module.changeset(%{archived: true})
    |> Handin.Repo.update()
  end

  @spec unarchive_module(Module.t()) :: {:ok, Module.t()} | {:error, String.t()}
  def unarchive_module(%Module{} = module) do
    module
    |> Module.changeset(%{archived: false})
    |> Handin.Repo.update()
  end

  @spec get_module_name(id :: Ecto.UUID) :: String.t()
  def get_module_name(id) do
    Module
    |> where([m], m.id == ^id)
    |> select([m], m.name)
    |> Repo.one()
  end

  @spec create_module(
          attrs :: %{name: String.t(), code: String.t(), term: String.t()},
          user_id :: Ecto.UUID
        ) ::
          {:ok, Module.t()} | {:error, %Ecto.Changeset{}}
  def create_module(attrs, user_id) do
    Multi.new()
    |> Multi.insert(:module, Module.changeset(%Module{}, attrs))
    |> Multi.insert(:modules_users, fn %{module: module} ->
      ModulesUsers.changeset(%ModulesUsers{}, %{module_id: module.id, user_id: user_id})
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{module: module}} -> {:ok, module}
      {:error, :module, changeset, %{}} -> {:error, changeset}
    end
  end

  @spec add_student(params :: %{user_id: Ecto.UUID, module_id: Ecto.UUID}) ::
          {:ok, ModulesUsers.t()}
  def add_student(params) do
    ModulesUsers.changeset(%ModulesUsers{}, params) |> Repo.insert(on_conflict: :nothing)
  end

  def update_module(%Module{} = module, attrs) do
    module
    |> Module.changeset(attrs)
    |> Repo.update()
  end

  def delete_module(%Module{} = module) do
    Repo.delete(module)
  end

  def change_module(%Module{} = module, attrs \\ %{}) do
    Module.changeset(module, attrs)
  end

  def change_modules_invitations(%ModulesInvitations{} = modules_invitations, attrs \\ %{}) do
    ModulesInvitations.changeset(modules_invitations, attrs)
  end

  @spec add_modules_invitations(params :: %{email: String.t(), module_id: Ecto.UUID}) ::
          {:ok, ModulesInvitations.t()}
  def add_modules_invitations(params) do
    change_modules_invitations(%ModulesInvitations{}, params)
    |> Repo.insert(on_conflict: :nothing)
  end

  def register_user_into_module(attrs) do
    %ModulesUsers{}
    |> ModulesUsers.changeset(attrs)
    |> Repo.insert()
  end

  def remove_user_from_module(user_id, module_id) do
    ModulesUsers
    |> where([mu], mu.user_id == ^user_id and mu.module_id == ^module_id)
    |> preload([:user, :module])
    |> Repo.one()
    |> Repo.delete()
  end

  def fetch_module_names() do
    Module
    |> select([m], m.name)
    |> Repo.all()
  end

  def check_and_add_new_user_modules_invitations(user) do
    ModulesInvitations
    |> where([mi], mi.email == ^user.email)
    |> Repo.all()
    |> Enum.each(fn module_invitation ->
      add_student(%{
        user_id: user.id,
        module_id: module_invitation.module_id
      })

      Repo.delete(module_invitation)
    end)
  end

  def get_modules_invitations(mi_id) do
    ModulesInvitations
    |> where([mi], mi.id == ^mi_id)
    |> Repo.one()
  end

  def delete_modules_invitations(id) do
    ModulesInvitations
    |> where([mi], mi.id == ^id)
    |> Repo.one()
    |> Repo.delete()
  end

  def assignment_exists?(module_id, assignment_id) do
    get_module!(module_id)
    |> Map.get(:assignments)
    |> Enum.any?(&(&1.id == assignment_id))
  end

  def list_assignments_for(id, user) do
    Module
    |> where([m], m.id == ^id)
    |> join(:inner, [m], a in assoc(m, :assignments), on: a.module_id == ^id)
    |> order_by([m, a], asc: a.start_date)
    |> select([m, a], a)
    |> maybe_filter_by_released_assignment(user)
    |> Repo.all()
    |> Repo.preload([:programming_language])
  end

  defp maybe_filter_by_released_assignment(query, user) do
    case user.role do
      :student ->
        now = DateTime.utc_now() |> DateTime.shift_zone!(user.university.timezone)

        query
        |> where(
          [m, a],
          a.id in subquery(
            CustomAssignmentDate
            |> select([cad], cad.assignment_id)
            |> where([cad], cad.user_id == ^user.id and cad.start_date <= ^now)
          ) or a.start_date <= ^now
        )

      _ ->
        query
    end
  end

  @spec add_users_to_module(AddUserToModuleParams.t()) ::
          {:ok, any()} | {:error, any()}
  def add_users_to_module(%AddUserToModuleParams{
        emails: emails,
        university_id: university_id,
        module: module
      })
      when is_list(emails) and not is_nil(university_id) do
    Multi.new()
    |> Multi.run(:users, fn _repo, _changes ->
      Enum.reduce_while(emails, {:ok, []}, fn email, {:ok, acc} ->
        case ensure_user(email, university_id) do
          {:ok, user} -> {:cont, {:ok, [user | acc]}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end)
    |> Multi.run(:module_users, fn _repo, %{users: users} ->
      Enum.reduce_while(users, {:ok, []}, fn user, {:ok, acc} ->
        case add_user_to_module(user.id, module.id) do
          {:ok, module_user} -> {:cont, {:ok, [module_user | acc]}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end)
    |> Multi.run(:emails, fn _repo, %{users: users} ->
      Enum.reduce_while(users, {:ok, []}, fn user, {:ok, acc} ->
        case send_emails(user, module.name) do
          :ok -> {:cont, {:ok, [user.email | acc]}}
          {:error, reason} -> {:halt, {:error, reason}}
        end
      end)
    end)
    |> Repo.transaction()
  end

  defp ensure_user(email, university_id) do
    case Accounts.get_user_by_email(email) do
      nil -> create_user(email, university_id)
      user -> {:ok, user}
    end
  end

  defp create_user(email, university_id) do
    temp_password = generate_temp_password()

    user_params = %{
      email: email,
      password: temp_password,
      university: university_id,
      role: :student
    }

    case Accounts.register_user(user_params) do
      {:ok, user} -> {:ok, Map.put(user, :temp_password, temp_password)}
      error -> error
    end
  end

  defp generate_temp_password do
    :crypto.strong_rand_bytes(12) |> Base.encode64() |> binary_part(0, 12)
  end

  defp add_user_to_module(user_id, module_id) do
    ModulesUsers.changeset(%ModulesUsers{}, %{user_id: user_id, module_id: module_id})
    |> Repo.insert()
  end

  defp send_emails(user, module_name) do
    with {:ok, _} <-
           UserNotifier.deliver_temporary_password_email(user.email, user.temp_password),
         {:ok, _} <- UserNotifier.deliver_module_addition(user.email, module_name) do
      :ok
    end
  end

  def get_teaching_assistants(module_id) do
    from(mu in ModulesUsers,
      where: mu.module_id == ^module_id and mu.role == :teaching_assistant,
      join: u in assoc(mu, :user),
      select: u
    )
    |> Repo.all()
  end

  @spec add_teaching_assistant(ModuleUsersParams.t()) ::
          {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  def add_teaching_assistant(%ModuleUsersParams{} = params) do
    %ModulesUsers{}
    |> ModulesUsers.changeset(Map.from_struct(params))
    |> Repo.insert()
    |> case do
      {:ok, module_user} -> {:ok, module_user |> Repo.preload(:user) |> Map.get(:user)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @spec remove_teaching_assistant(Ecto.UUID.t(), Ecto.UUID.t()) ::
          {:ok, User.t()} | {:error, %Ecto.Changeset{}}
  def remove_teaching_assistant(user_id, module_id) do
    from(mu in ModulesUsers,
      where:
        mu.user_id == ^user_id and mu.module_id == ^module_id and mu.role == :teaching_assistant,
      preload: [:user],
      select: mu
    )
    |> Repo.one()
    |> Repo.delete()
  end
end
