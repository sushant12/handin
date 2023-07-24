defmodule HandinWeb.UserForgotPasswordLive do
  use HandinWeb, :live_view

  alias Handin.Accounts

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-md w-[28rem]">
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
            <.header class="text-center">
              Forgot your password?
              <:subtitle>We'll send a password reset link to your inbox</:subtitle>
            </.header>
          </h1>

          <.simple_form
            for={@form}
            id="reset_password_form"
            phx-submit="send_email"
            class="space-y-4 md:space-y-6"
          >
            <.input
              field={@form[:email]}
              type="email"
              placeholder="Email"
              required
              class="bg-gray-50 border border-gray-300 text-gray-900 sm:text-sm rounded-lg focus:ring-primary-600 focus:border-primary-600 block w-full p-2.5 dark:bg-gray-700 dark:border-gray-600 dark:placeholder-gray-400 dark:text-white dark:focus:ring-blue-500 dark:focus:border-blue-500"
            />
            <:actions>
              <.button
                phx-disable-with="Sending..."
                class="w-full text-white bg-primary-600 hover:bg-primary-700 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
              >
                Send password reset instructions
              </.button>
            </:actions>
          </.simple_form>

          <p class="text-center text-sm mt-4 text-gray-600 dark:text-gray-400">
            <.link href={~p"/users/register"}>Register</.link>
            | <.link href={~p"/users/log_in"}>Log in</.link>
          </p>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info =
      "If your email is in our system, you will receive instructions to reset your password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
