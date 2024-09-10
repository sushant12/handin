defmodule HandinWeb.Admin.UserHTML do
  use HandinWeb, :html

  import Phoenix.HTML.Form
  use PhoenixHTMLHelpers

  alias Handin.Universities

  import Torch.TableView
  import Torch.FilterView
  import Torch.Component

  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, Torch.Component.translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  embed_templates "user_html/*"
end