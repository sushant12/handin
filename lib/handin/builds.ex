defmodule Handin.Builds do
  @moduledoc """
  The Builds context.
  only built for purpose of Torch Admin panel

  use Assginments context
  """

  use Torch.Pagination,
    repo: Handin.Repo,
    model: Handin.Assignments.Build,
    name: :builds
end
