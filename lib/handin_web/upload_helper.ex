defmodule HandinWeb.UploadHelper do
  def get_file_format(binary) do
    case binary do
      <<"%PDF", _rest::binary>> ->
        {:ok, "pdf"}

      <<0xFF, 0xD8, 0xFF, _rest::binary>> ->
        {:ok, "jpg"}

      <<0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, _rest::binary>> ->
        {:ok, "png"}

      _ ->
        {:error, :invalid_file}
    end
  end
end
