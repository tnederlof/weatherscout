defmodule WeatherScoutWeb.LayoutView do
  use WeatherScoutWeb, :view

  @doc """
  Set css class for active link.
  """
  def css_class(conn, path, prefix \\ "") do
    default_class =
      "inline-flex items-center px-1 pt-1 border-b-2 border-transparent text-sm font-medium leading-5 text-gray-500 hover:text-gray-700 hover:border-gray-300 focus:outline-none focus:text-gray-700 focus:border-gray-300 transition duration-150 ease-in-out"

    active_class =
      "inline-flex items-center px-1 pt-1 border-b-2 border-indigo-500 text-sm font-medium leading-5 text-gray-900 focus:outline-none focus:border-indigo-700 transition duration-150 ease-in-out"

    if path == Phoenix.Controller.current_path(conn) do
      prefix <> active_class
    else
      prefix <> default_class
    end
  end

  @doc """
  Set css class for active link.
  """
  def mobile_css_class(conn, path, prefix \\ "") do
    default_class =
      "block px-3 py-2 rounded-md text-base font-medium text-gray-300 hover:text-white hover:bg-gray-700 focus:outline-none focus:text-white focus:bg-gray-700"

    active_class =
      "block px-3 py-2 rounded-md text-base font-medium text-white bg-gray-900 focus:outline-none focus:text-white focus:bg-gray-700"

    if path == Phoenix.Controller.current_path(conn) do
      prefix <> active_class
    else
      prefix <> default_class
    end
  end
end
