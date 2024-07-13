defmodule HandinWeb.UserRegistrationLive do
  use HandinWeb, :live_view

  alias Handin.{Accounts, Modules, Universities}
  alias Handin.Accounts.User

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
            Create and account
          </h1>
          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/users/log_in?_action=registered"}
            method="post"
            class="space-y-4 md:space-y-6"
          >
            <.error :if={@check_errors}>
              Oops, something went wrong! Please check the errors below.
            </.error>
            <div>
              <.input
                field={@form[:university_id]}
                type="select"
                prompt="Select your university"
                options={@universities}
                label="University"
                required
              />
            </div>
            <div>
              <.input
                field={@form[:role]}
                type="select"
                prompt="Select your role"
                options={[{"Lecturer", "lecturer"}, {"Student", "student"}]}
                label="Role"
                required
              />
            </div>
            <div>
              <.input
                field={@form[:email]}
                label="Email"
                type="email"
                required
                placeholder="email@example.com"
              />
            </div>
            <div>
              <.input
                field={@form[:password]}
                label="Password"
                type="password"
                placeholder="••••••••"
                required
              />
            </div>
            <div>
              <.input
                field={@form[:password_confirmation]}
                label="Confirm password"
                type="password"
                placeholder="••••••••"
                required
              />
            </div>

            <:actions>
              <.button
                phx-disable-with="Creating account..."
                class="w-full text-white bg-primary-600 hover:bg-primary-700 focus:ring-4 focus:outline-none focus:ring-primary-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center dark:bg-primary-600 dark:hover:bg-primary-700 dark:focus:ring-primary-800"
              >
                Create an account
              </.button>
            </:actions>
            <p class="text-sm font-light text-gray-500 dark:text-gray-400">
              Already have an account?
              <.link
                navigate={~p"/users/log_in"}
                class="font-medium text-primary-600 hover:underline dark:text-primary-500"
              >
                Login here
              </.link>
            </p>
          </.simple_form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    universities =
      Universities.list_universities()
      |> Enum.map(&{&1.name, &1.id})

    changeset =
      Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign(:universities, universities)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    with {:ok, user} <-
           Accounts.register_user(user_params) do
      {:ok, _} =
        Accounts.deliver_user_confirmation_instructions(
          user,
          &url(~p"/users/confirm/#{&1}")
        )

      Modules.check_and_add_new_user_modules_invitations(user)

      changeset = Accounts.change_user_registration(user)

      {:noreply,
       socket
       |> assign(trigger_submit: true)
       |> assign_form(changeset)
       |> put_flash(:info, "User created successfully")}
    else
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(check_errors: true)
         |> assign_form(changeset)
         |> put_flash(:error, "Oops, something went wrong!")}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
