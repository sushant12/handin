defmodule HandinWeb.Admin.AssignmentTestHTML do
  use HandinWeb, :html

  import Phoenix.HTML.Form
  use PhoenixHTMLHelpers

  import Torch.Component

  def error_tag(form, field) do
    Enum.map(Keyword.get_values(form.errors, field), fn error ->
      content_tag(:span, Torch.Component.translate_error(error),
        class: "invalid-feedback",
        phx_feedback_for: input_name(form, field)
      )
    end)
  end

  embed_templates "assignment_test_html/*"
end
