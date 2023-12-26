defmodule Handin.DisplayHelper do
  use Timex

  def format_date(date_time, _timezone) do
    # converted_date = Timex.Timezone.convert(date, timezone)
    Timex.format!(date_time, "%b %e, %Y at %H:%M:%S %p", :strftime)
  end
end
