defmodule RealtimeWeb.ExecutionView do
  use RealtimeWeb, :view

  def render("index.json", %{executions: executions}) do
    executions
  end
end
