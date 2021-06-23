defmodule WeatherScoutWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers
  import Phoenix.LiveView

  @doc """
  Renders a component inside the `WeatherScoutWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, WeatherScoutWeb.EventLive.FormComponent,
        id: @event.id || :new,
        action: @live_action,
        event: @event,
        return_to: Routes.event_index_path(@socket, :index) %>
  """
  def live_modal(socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(socket, WeatherScoutWeb.ModalComponent, modal_opts)
  end

  @doc """
  Assigns a current_user to the socket if one is logged in, otherwise redirects to login page.

  This helper is designed to be used in the mount function of a page using liveview and user authentication.

  ## Examples

    {:ok, assign_defaults(session, socket)}
  """
  def assign_defaults(session, socket) do
    socket =
      assign_new(socket, :current_user, fn ->
        WeatherScout.Accounts.get_user_by_session_token(session["user_token"])
      end)

    if !is_nil(socket.assigns.current_user) do
      if socket.assigns.current_user.confirmed_at do
        socket
      else
        redirect(socket, to: "/users/login")
      end
    else
      redirect(socket, to: "/users/login")
    end
  end
end
