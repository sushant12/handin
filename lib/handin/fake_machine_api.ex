defmodule Handin.FakeMachineApi do
  def create(params) do
    case params do
      %{"fail" => true} ->
        {:error, %{reason: :timeout}}

      _ ->
        {:ok,
         %{
           "config" => %{
             "guest" => %{"cpu_kind" => "shared", "cpus" => 1, "memory_mb" => 256},
             "image" => "sushantbajracharya/cpp:latest",
             "init" => %{},
             "restart" => %{}
           },
           "created_at" => "2023-08-22T21:56:23Z",
           "events" => [
             %{
               "id" => "01H8FKZCZ80VBJQT2NKD5PZJFP",
               "source" => "user",
               "status" => "created",
               "timestamp" => 1_692_741_383_144,
               "type" => "launch"
             }
           ],
           "id" => "e82d924a071268",
           "image_ref" => %{
             "digest" =>
               "sha256:bc045974de8bbecb2be4b919104df428f227543e366140ee247fcecc2327196a",
             "labels" => nil,
             "registry" => "registry-1.docker.io",
             "repository" => "sushantbajracharya/cpp",
             "tag" => "latest"
           },
           "instance_id" => "01H8FKZCW79S88KGA0WW9G71Q2",
           "name" => "polished-smoke-3606",
           "private_ip" => "fdaa:2:c48c:a7b:13d:b671:768:2",
           "region" => "lhr",
           "state" => "created",
           "updated_at" => "2023-08-22T21:56:23Z"
         }}
    end
  end

  def stop(_machine_id) do
    {:ok, ""}
  end

  def destroy(_machine_id) do
    {:ok, ""}
  end

  def status(_machine_id) do
    Enum.random([
      {:ok, %{"state" => "started"}},
      {:error, "not started"}
    ])

    # NOTE: Uncomment the following line to test the happy path

    # {:ok, %{"state" => "started"}}
    # {:error, "not started"}
  end

  def exec(_machine_id, _cmd) do
    state = Enum.random(["pass", "fail"])

    Enum.random([
      {:ok,
       %{
         "stdout" =>
           Jason.encode!(%{
             "state" => state,
             "stderr" => "incorrect test test",
             "output" => "Good job!"
           }),
         "exit_code" => 1
       }},
      {:error, "timeout"}
    ])

    # NOTE: Uncomment the following line to test the happy path

    # {:ok,
    #    %{
    #      "stdout" =>
    #        Jason.encode!(%{
    #          "state" => state,
    #          "stderr" => "incorrect test test",
    #          "output" => "Good job!"
    #        }),
    #      "exit_code" => 1
    #    }}

    # {:error, "timeout"}
  end
end
