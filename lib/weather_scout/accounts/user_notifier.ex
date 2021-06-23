defmodule WeatherScout.Accounts.UserNotifier do
  use Phoenix.Swoosh,
    view: WeatherScoutWeb.EmailView,
    layout: {WeatherScoutWeb.LayoutView, :email}

  alias WeatherScout.Mailer

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    new()
    |> to({user.email, user.email})
    |> from({"The Weather Scout", "no-reply@theweatherscout.com"})
    |> subject("Welcome to The Weather Scout! Confirm Your Email")
    |> render_body("email_confirmation.html", %{email: user.email, url: url})
    |> Mailer.deliver()
  end

  @doc """
  Deliver instructions to reset password account.
  """
  def deliver_reset_password_instructions(user, url) do
    new()
    |> to({user.email, user.email})
    |> from({"The Weather Scout", "no-reply@theweatherscout.com"})
    |> subject("Reset Your Password at The Weather Scout")
    |> render_body("password_reset.html", %{email: user.email, url: url})
    |> Mailer.deliver()
  end

  @doc """
  Deliver instructions to update your e-mail.
  """
  def deliver_update_email_instructions(user, url) do
    new()
    |> to({user.email, user.email})
    |> from({"The Weather Scout", "no-reply@theweatherscout.com"})
    |> subject("Update Your Email at The Weather Scout")
    |> render_body("email_update.html", %{email: user.email, url: url})
    |> Mailer.deliver()
  end
end
