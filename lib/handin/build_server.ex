defmodule Handin.BuildServer do
  use GenServer
  alias Handin.Assignments
  alias Handin.{SupportFileUploader, AssignmentSubmissionFileUploader}
  alias Handin.AssignmentSubmission.AssignmentSubmissionFile

  @machine_api Application.compile_env(:handin, :machine_api_module)

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: name_for(state))
  end

  def name_for(state) do
    if state.type == "assignment_tests" do
      {:global, "build:#{state.type}:#{state.assignment_id}"}
    else
      {:global, "build:#{state.type}:#{state.assignment_submission_id}"}
    end
  end

  @impl true
  def init(state) do
    assignment = Assignments.get_assignment!(state.assignment_id)

    {:ok, build} =
      Assignments.new_build(%{
        assignment_id: assignment.id,
        status: :running,
        user_id: state.user_id
      })

    state = state |> Map.put(:assignment, assignment) |> Map.put(:build, build)

    {:ok, state, {:continue, :create_machine}}
  end

  @impl true
  def handle_continue(:create_machine, state) do
    with {:ok, machine} <-
           @machine_api.create(
             Jason.encode!(%{
               config: %{
                 init: %{
                   exec: ["/bin/sleep", "inf"]
                 },
                 auto_destroy: true,
                 image: state.image,
                 files:
                   build_main_script(state.assignment) ++
                     build_file_download_script(state.assignment, state.type, state.user_id) ++
                     build_upload_script(state.assignment, state) ++
                     build_check_script(state.assignment) ++
                     build_tests_scripts(state.assignment)
               }
             })
           ),
         true <- machine_started?(machine),
         {:ok, build} <- Assignments.update_build(state.build, %{machine_id: machine["id"]}) do
      state = state |> Map.put(:machine_id, machine["id"]) |> Map.put(:build, build)

      {:noreply, state, {:continue, :process_build}}
    else
      _ ->
        Assignments.update_build(state.build, %{status: :failed})

        {:stop, "Failed To Create Container", state}
    end
  end

  def handle_continue(:process_build, state) do
    with {:file, {:ok, %{"exit_code" => 0}}} <-
           {:file, @machine_api.exec(state.machine_id, "sh ./files.sh")},
         {:ok, %{"exit_code" => 0} = response} <-
           @machine_api.exec(state.machine_id, "sh ./main.sh") do
      Assignments.save_run_script_results(%{
        assignment_id: state.assignment.id,
        state: :pass,
        build_id: state.build.id,
        user_id: state.user_id
      })

      log_and_broadcast(
        state.build,
        %{command: "sh ./main.sh", output: response["stdout"]},
        state
      )

      state.assignment.assignment_tests
      |> Enum.map(&{"#{&1.id}.sh", &1})
      |> Enum.each(fn {file_name, assignment_test} ->
        case @machine_api.exec(state.machine_id, "sh ./#{file_name}") do
          {:ok, %{"exit_code" => 0} = response} ->
            :timer.sleep(3000)

            case response["stdout"]
                 |> Jason.decode() do
              {:ok, response} ->
                test_state = if response["state"] == "pass", do: :pass, else: :fail

                Assignments.save_test_results(%{
                  assignment_test_id: assignment_test.id,
                  state: test_state,
                  build_id: state.build.id,
                  user_id: state.user_id
                })

                log_and_broadcast(
                  state.build,
                  %{
                    command: assignment_test.command,
                    assignment_test_id: assignment_test.id,
                    output: response["output"],
                    expected_output: response["expected_output"]
                  },
                  state
                )

              {:error, response} ->
                Assignments.save_test_results(%{
                  assignment_test_id: assignment_test.id,
                  state: :fail,
                  build_id: state.build.id,
                  user_id: state.user_id
                })

                log_and_broadcast(
                  state.build,
                  %{
                    command: assignment_test.command,
                    assignment_test_id: assignment_test.id,
                    output:
                      "Error parsing json at position #{response.position}, data: #{response.data}"
                  },
                  state
                )
            end

          {:ok, response} ->
            Assignments.save_test_results(%{
              assignment_test_id: assignment_test.id,
              state: :fail,
              build_id: state.build.id,
              user_id: state.user_id
            })

            log_and_broadcast(
              state.build,
              %{
                command: assignment_test.command,
                assignment_test_id: assignment_test.id,
                output: response["stderr"]
              },
              state
            )

          {:error, "deadline_exceeded:" <> _reason} ->
            :timer.sleep(3000)

            case @machine_api.exec(state.machine_id, "sh ./check_#{file_name}") do
              {:ok, %{"exit_code" => 0} = response} ->
                case response["stdout"]
                     |> Jason.decode() do
                  {:ok, response} ->
                    test_state = if response["state"] == "pass", do: :pass, else: :fail

                    Assignments.save_test_results(%{
                      assignment_test_id: assignment_test.id,
                      state: test_state,
                      build_id: state.build.id,
                      user_id: state.user_id
                    })

                    log_and_broadcast(
                      state.build,
                      %{
                        command: assignment_test.command,
                        assignment_test_id: assignment_test.id,
                        output: response["output"],
                        expected_output: response["expected_output"]
                      },
                      state
                    )

                  {:error, response} ->
                    Assignments.save_test_results(%{
                      assignment_test_id: assignment_test.id,
                      state: :fail,
                      build_id: state.build.id,
                      user_id: state.user_id
                    })

                    log_and_broadcast(
                      state.build,
                      %{
                        command: assignment_test.command,
                        assignment_test_id: assignment_test.id,
                        output:
                          "Error parsing json at position #{response.position}, data: #{response.data}"
                      },
                      state
                    )
                end

              {:error, response} ->
                Assignments.save_test_results(%{
                  assignment_test_id: assignment_test.id,
                  state: :fail,
                  build_id: state.build.id,
                  user_id: state.user_id
                })

                log_and_broadcast(
                  state.build,
                  %{
                    command: assignment_test.command,
                    assignment_test_id: assignment_test.id,
                    output:
                      "Error parsing json at position #{response.position}, data: #{response.data}"
                  },
                  state
                )
            end

          {:error, reason} ->
            Assignments.save_test_results(%{
              assignment_test_id: assignment_test.id,
              state: :fail,
              build_id: state.build.id,
              user_id: state.user_id
            })

            log_and_broadcast(
              state.build,
              %{
                command: assignment_test.command,
                assignment_test_id: assignment_test.id,
                output: reason
              },
              state
            )
        end
      end)

      Assignments.update_build(state.build, %{status: :completed})
    else
      {:file, {:ok, %{"exit_code" => _} = reason}} ->
        Assignments.update_build(state.build, %{status: :failed})

        log_and_broadcast(
          state.build,
          %{command: "sh ./main.sh", output: reason["stderr"]},
          state
        )

      {:ok, %{"exit_code" => _} = reason} ->
        Assignments.update_build(state.build, %{status: :failed})

        Assignments.save_run_script_results(%{
          assignment_id: state.assignment.id,
          state: :fail,
          build_id: state.build.id,
          user_id: state.user_id
        })

        log_and_broadcast(
          state.build,
          %{command: "sh ./main.sh", output: reason["stderr"]},
          state
        )
    end

    Assignments.get_logs(state.build.id)

    if state.type == "assignment_tests" do
      HandinWeb.Endpoint.broadcast!(
        "build:#{state.type}:#{state.assignment_id}",
        "build_completed",
        state.build.id
      )
    else
      HandinWeb.Endpoint.broadcast!(
        "build:#{state.type}:#{state.assignment_submission_id}",
        "build_completed",
        state.build.id
      )
    end

    @machine_api.exec(state.machine_id, "sh ./upload.sh")
    @machine_api.stop(state.machine_id)

    {:stop, "Server terminated gracefully", state}
  end

  defp machine_started?(machine) do
    case @machine_api.status(machine["id"]) do
      {:ok, %{"state" => state}} when state in ["created", "starting"] ->
        :timer.sleep(1000)
        machine_started?(machine)

      _ ->
        true
    end
  end

  defp log_and_broadcast(build, log_map, state) do
    log_map = log_map |> Map.put(:build_id, build.id)
    Assignments.log(log_map)

    if state.type == "assignment_tests" do
      HandinWeb.Endpoint.broadcast!(
        "build:#{state.type}:#{state.assignment_id}",
        "test_result",
        build.id
      )
    else
      HandinWeb.Endpoint.broadcast!(
        "build:#{state.type}:#{state.assignment_submission_id}",
        "test_result",
        build.id
      )
    end
  end

  defp build_check_script(assignment) do
    assignment.assignment_tests
    |> Enum.map(fn assignment_test ->
      template = """
      #!/bin/bash
      if diff -q #{assignment_test.id}.out #{assignment_test.expected_output_file} >/dev/null; then
        state="pass"
      else
        state="fail"
      fi
      JSON_FMT='{"state": "%s"}'
      printf "$JSON_FMT" "$state"
      """

      %{
        "guest_path" => "/check_#{assignment_test.id}.sh",
        "raw_value" => Base.encode64(template)
      }
    end)
  end

  defp build_file_download_script(assignment, type, user_id) do
    template = """
    #!bin/bash
    """

    assignment_files =
      if type == "assignment_tests" do
        assignment.support_files ++ assignment.solution_files
      else
        assignment.support_files ++ Assignments.get_submission_files(assignment.id, user_id)
      end

    urls =
      assignment_files
      |> Enum.map(fn assignment_file ->
        case assignment_file do
          %AssignmentSubmissionFile{} = assignment_file ->
            AssignmentSubmissionFileUploader.url(
              {assignment_file.file.file_name, assignment_file},
              signed: true
            )

          _ ->
            SupportFileUploader.url({assignment_file.file.file_name, assignment_file},
              signed: true
            )
        end
      end)
      |> Enum.map(fn url ->
        """
        curl -O "#{url}"
        """
      end)

    [
      %{
        "guest_path" => "/files.sh",
        "raw_value" => Base.encode64(template <> Enum.join(urls, "\n"))
      }
    ]
  end

  defp build_main_script(assignment) do
    template = """
      #!bin/bash
      #{assignment.run_script}
    """

    [
      %{
        "guest_path" => "/main.sh",
        "raw_value" => Base.encode64(template)
      }
    ]
  end

  defp build_upload_script(assignment, state) do
    config = ExAws.Config.new(:s3, Application.get_all_env(:ex_aws))

    template = """
    #!/bin/bash
    """

    curls =
      assignment.assignment_tests
      |> Enum.map(fn assignment_test ->
        if state.type == "assignment_tests" do
          {:ok, presigned_url} =
            ExAws.S3.presigned_url(
              config,
              :put,
              "handin-dev",
              "uploads/assignment/solution/#{assignment_test.id}.out",
              expires_in: 6000
            )

          "curl --request PUT --upload-file \"#{assignment_test.id}.out\" \"#{presigned_url}\""
        else
          {:ok, presigned_url} =
            ExAws.S3.presigned_url(
              config,
              :put,
              "handin-dev",
              "uploads/user/#{state.user_id}/assignment/#{assignment.id}/submission/solution/#{assignment_test.id}.out",
              expires_in: 600
            )

          "curl --request PUT --upload-file \"#{assignment_test.id}.out\" \"#{presigned_url}\""
        end
      end)

    template = template <> Enum.join(curls, "\n")

    [
      %{
        "guest_path" => "/upload.sh",
        "raw_value" => Base.encode64(template)
      }
    ]
  end

  defp build_tests_scripts(assignment) do
    assignment.assignment_tests
    |> Enum.map(fn assignment_test ->
      template =
        if assignment_test.enable_custom_test do
          assignment_test.custom_test
        else
          if assignment_test.expected_output_type == :string do
            """
            #!/bin/bash
            output=$(#{assignment_test.command})
            echo "$output" > #{assignment_test.id}.out
            expected_output=#{assignment_test.expected_output_text}
            if [ "$output" = "$expected_output" ]; then
              state="pass"
            else
              state="fail"
            fi
            #output=$(echo "$output" | base64 --wrap=0)
            #expected_output=$(echo "$expected_output" | base64 --wrap=0)
            #JSON_FMT='{"state": "%s", "output":"%s", "expected_output": "%s"}'
            #printf "$JSON_FMT" "$state" "$output" "$expected_output"
            JSON_FMT='{"state": "%s"}'
            printf "$JSON_FMT" "$state"
            """
          else
            """
            #!/bin/bash
            # output="#{assignment_test.command}"
            # $output > #{assignment_test.id}.out 2>&1 &
            output=$(#{assignment_test.command})
            echo "$output" > #{assignment_test.id}.out
            if diff -q #{assignment_test.id}.out #{assignment_test.expected_output_file} >/dev/null; then
              state="pass"
            else
              state="fail"
            fi
            #output=$(echo "$output" | base64 --wrap=0)
            #expected_output=$(echo "$expected_output" | base64 --wrap=0)
            #JSON_FMT='{"state": "%s", "output":"%s", "expected_output": "%s"}'
            #printf "$JSON_FMT" "$state" "$output" "$expected_output"
            JSON_FMT='{"state": "%s"}'
            printf "$JSON_FMT" "$state"
            """
          end

          # "expected_output=$(< #{assignment_test.expected_output_file})"
        end

      %{
        "guest_path" => "/#{assignment_test.id}.sh",
        "raw_value" => Base.encode64(template)
      }
    end)
  end
end
