defmodule RealtimeWeb.ErrorView do
  use RealtimeWeb, :view

  require Logger

  def render("500.json", _assigns) do
    %{message: "internal server error"}
  end

  def render("400.json", _assigns) do
    %{message: "bad request"}
  end

  def render("404.json", _assigns) do
    %{message: "not found"}
  end

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
