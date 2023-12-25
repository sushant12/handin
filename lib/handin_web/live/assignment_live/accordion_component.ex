defmodule HandinWeb.AssignmentLive.AccordionComponent do
  use Phoenix.Component

  def accordion(assigns) do
    ~H"""
    <div id="accordion-open" data-accordion="open">
      <%= for {index, log} <- @logs do %>
        <h2 id={"accordion-open-heading-#{index}"}>
          <button
            type="button"
            class={[
              "flex items-center justify-between w-full p-5 font-medium rtl:text-right border border-b-0 border-gray-200 focus:ring-4 focus:ring-gray-200 dark:focus:ring-gray-800 dark:border-gray-700 dark:text-gray-400 hover:bg-gray-100 dark:hover:bg-gray-800 gap-3",
              log.state == :pass && "text-green-500",
              log.state == :fail && "text-red-600"
            ]}
            data-accordion-target={"#accordion-open-body-#{index}"}
            aria-expanded="false"
            aria-controls={"accordion-open-body-#{index}"}
          >
            <span class="flex items-center">
              <svg
                :if={log.state == :pass}
                class="w-6 h-6 text-green-500 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M10 .5a9.5 9.5 0 1 0 9.5 9.5A9.51 9.51 0 0 0 10 .5Zm3.707 8.207-4 4a1 1 0 0 1-1.414 0l-2-2a1 1 0 0 1 1.414-1.414L9 10.586l3.293-3.293a1 1 0 0 1 1.414 1.414Z" />
              </svg>
              <svg
                :if={log.state == :fail}
                class="w-6 h-6 text-red-600 dark:text-white"
                aria-hidden="true"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 20 20"
              >
                <path
                  stroke="currentColor"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="m13 7-6 6m0-6 6 6m6-3a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                />
              </svg>
              <%= log.name %>
            </span>
            <svg
              data-accordion-icon
              class="w-3 h-3 rotate-180 shrink-0"
              aria-hidden="true"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 10 6"
            >
              <path
                stroke="currentColor"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-width="2"
                d="M9 5 5 1 1 5"
              />
            </svg>
          </button>
        </h2>
        <div
          id={"accordion-open-body-#{index}"}
          class="hidden"
          aria-labelledby={"accordion-open-heading-#{index}"}
        >
          <div class="p-5 border border-b-0 border-gray-200 dark:border-gray-700 dark:bg-gray-900">
            <p class="font-semibold">Expected Output:</p>
            <p class="mb-2 text-gray-500 dark:text-gray-400">
              <%= log.expected_output %>
            </p>
            <p class="font-semibold">Got:</p>
            <p class="text-gray-500 dark:text-gray-400">
              <%= log.output %>
            </p>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
