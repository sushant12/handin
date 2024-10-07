defmodule Handin.DisplayHelper do
  alias Handin.Accounts.User

  def format_date(date_time) do
    Calendar.strftime(date_time, "%b %d, %Y at %H:%M:%S %p")
  end

  def get_full_name(%User{first_name: first_name, last_name: last_name})
      when is_binary(first_name) and is_binary(last_name) do
    first_name <> " " <> last_name
  end

  def get_full_name(_), do: ""
end
