defmodule Handin.MachineApi do
  def create(params) do
    case Finch.build(
           :post,
           "#{Application.get_env(:handin, :fly_base_url)}container/machines",
           [{"authorization", "Bearer #{Application.get_env(:handin, :fly_auth_token)}"}],
           params
         )
         |> Finch.request(Handin.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def stop(machine_id) do
    case Finch.build(
           :post,
           "#{Application.get_env(:handin, :fly_base_url)}container/machines/#{machine_id}/stop",
           [{"authorization", "Bearer #{Application.get_env(:handin, :fly_auth_token)}"}],
           %{}
         )
         |> Finch.request(Handin.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def destroy(machine_id) do
    case Finch.build(
           :post,
           "#{Application.get_env(:handin, :fly_base_url)}container/machines/#{machine_id}",
           [{"authorization", "Bearer #{Application.get_env(:handin, :fly_auth_token)}"}],
           %{}
         )
         |> Finch.request(Handin.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def status(machine_id) do
    case Finch.build(
           :get,
           "#{Application.get_env(:handin, :fly_base_url)}container/machines/#{machine_id}",
           [{"authorization", "Bearer #{Application.get_env(:handin, :fly_auth_token)}"}],
           %{}
         )
         |> Finch.request(Handin.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def exec(machine_id, cmd) do
    case Finch.build(
           :post,
           "#{Application.get_env(:handin, :fly_base_url)}container/machines/#{machine_id}/exec",
           [{"authorization", "Bearer #{Application.get_env(:handin, :fly_auth_token)}"}],
           %{cmd: cmd}
         )
         |> Finch.request(Handin.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
