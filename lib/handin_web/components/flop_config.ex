defmodule HandinWeb.FlopConfig do
  def table_opts do
    [
      table_attrs: [class: "w-full text-sm text-left text-gray-500 dark:text-gray-400"],
      thead_th_attrs: [class: "px-6 py-3"],
      thead_tr_attrs: [
        class: "text-xs text-gray-700 uppercase bg-gray-50 dark:bg-gray-700 dark:text-gray-400"
      ],
      tbody_td_attrs: [
        class: "px-6 py-4 font-medium text-gray-900 whitespace-nowrap dark:text-white"
      ],
      tbody_tr_attrs: [class: "bg-white border-b dark:bg-gray-800 dark:border-gray-700"]
    ]
  end

  def pagination_opts do
    [
      page_links: {:ellipsis, 3},
      # The attributes for the <nav> element that wraps the pagination links
      wrapper_attrs: [class: "inline-flex text-sm -space-x-px text-gray-500 bg-white"],
      previous_link_attrs: [
        class:
          "flex items-center justify-center px-4 h-10 ms-0 leading-tight hover:bg-gray-100 hover:text-gray-700 border border-e-0 border-gray-300 rounded-s-lg"
      ],
      previous_link_content:
        Phoenix.HTML.raw(
          "<svg class='w-2.5 h-2.5 rtl:rotate-180' aria-hidden='true' xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 6 10'><path stroke='currentColor' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M5 1 1 5l4 4'/></svg>"
        ),
      current_link_attrs: [
        class:
          "text-brand inline-flex items-center justify-center px-4 h-10 ms-0 leading-tight text-blue-600 bg-blue-50 pointer-events-none border border-gray-300"
      ],
      next_link_attrs: [
        class:
          "flex items-center justify-center px-4 h-10 ms-0 leading-tight hover:bg-gray-100 hover:text-gray-700 border border-e-0 border-gray-300 rounded-s-lg"
      ],
      next_link_content:
        Phoenix.HTML.raw(
          "<svg class='w-2.5 h-2.5 rtl:rotate-180' aria-hidden='true' xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 6 10'><path stroke='currentColor' stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='m1 9 4-4-4-4'/></svg>"
        ),
      ellipsis_attrs: [
        aria: [label: "Go to next page"],
        class:
          "px-4 flex items-center justify-center px-2 h-10 ms-0 leading-tight pointer-events-none text-gray-400"
      ],
      ellipsis_content: {:safe, "&#x22ef;"},
      pagination_list_attrs: [
        class: "inline-flex items-center justify-center h-10 ms-0 leading-tight"
      ],
      pagination_link_attrs: [
        class:
          "px-4 flex items-center justify-center px-4 h-10 ms-0 leading-tight hover:bg-gray-100 hover:text-gray-700 border border-gray-300"
      ]
    ]
  end
end
