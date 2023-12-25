defmodule Handin.DisplayHelper do
  use Timex

  def format_date(date, timezone) do
    date
    |> Timex.Timezone.convert(timezone)
    |> Timex.format!("%b %e, %Y at %H:%M:%S %p", :strftime)
  end
end
