defmodule HandinWeb.UserLoginLive do
  use HandinWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md w-[32rem]">
      <div class="w-full flex justify-center">
        <a
          href="#"
          class="flex items-center mb-6 text-2xl font-semibold text-gray-900 dark:text-white"
        >
          <img
            class="w-8 h-8 mr-2"
            src="https://flowbite.s3.amazonaws.com/blocks/marketing-ui/logo.svg"
            alt="logo"
          /> Handin
        </a>
      </div>
      <div class="w-full bg-white rounded-lg shadow dark:border md:mt-0 sm:max-w-md xl:p-0 dark:bg-gray-800 dark:border-gray-700">
        <div class="p-6 space-y-4 md:space-y-6 sm:p-8">
          <h1 class="text-xl font-bold leading-tight tracking-tight text-gray-900 md:text-2xl dark:text-white">
            Sign in to your account
          </h1>

          <.simple_form
            for={@form}
            id="login_form"
            action={~p"/users/log_in"}
            phx-update="ignore"
            class="space-y-4 md:space-y-6"
          >
            <.error :if={@flash["error"]}>
              <%= @flash["error"] %>
            </.error>
            <div>
              <.input
                field={@form[:email]}
                label="Email"
                type="email"
                class="bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                required
                placeholder="email@example.com"
              />
            </div>
            <div>
              <.input
                field={@form[:password]}
                label="Password"
                type="password"
                class="bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
                placeholder="••••••••"
                required
              />
            </div>
            <:actions>
              <div class="flex items-center justify-between w-full">
                <div class="flex items-start">
                  <div class="flex items-center h-5">
                    <.input
                      field={@form[:remember_me]}
                      type="checkbox"
                      class="w-4 h-4 border border-gray-300 rounded bg-gray-50 focus:ring-3 focus:ring-primary-300 dark:bg-gray-700 dark:border-gray-600 dark:focus:ring-primary-600 dark:ring-offset-gray-800"
                    />
                    <label class="ml-3 text-sm text-gray-500 dark:text-gray-300">
                      Keep me logged in
                    </label>
                  </div>
                </div>
                <.link
                  href={~p"/users/reset_password"}
                  class="text-sm font-medium text-primary-600 hover:underline dark:text-primary-500"
                >
                  Forgot your password?
                </.link>
              </div>
            </:actions>
            <p class="text-sm font-light text-gray-500 dark:text-gray-400">
              Don't have an account yet?
              <.link
                navigate={~p"/users/register"}
                class="font-medium text-primary-600 hover:underline dark:text-primary-500"
              >
                Sign up
              </.link>
            </p>
            <:actions>
              <.button
                phx-disable-with="Signing in..."
                class="w-full text-white bg-primary-600 hover:bg-primary-700 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
              >
                Sign in <span aria-hidden="true">→</span>
              </.button>
            </:actions>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
