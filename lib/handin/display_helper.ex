defmodule Handin.DisplayHelper do
  use Timex

  def format_date(date, timezone) do
    converted_date = Timex.Timezone.convert(date, timezone)
    Timex.format!(converted_date, "%b %e, %Y at %H:%M:%S %p", :strftime)
  end
end
