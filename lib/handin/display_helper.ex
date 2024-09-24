defmodule Handin.DisplayHelper do
  def format_date(date_time) do
    Calendar.strftime(date_time, "%b %d, %Y at %H:%M:%S %p")
  end
end
