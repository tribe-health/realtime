defmodule RealtimeWeb.WorkflowView do
  use RealtimeWeb, :view

  def render("index.json", %{workflows: workflows}) do
    workflows
  end

  def render("create.json", %{workflow: workflow}) do
    workflow
  end

  def render("update.json", %{workflow: workflow}) do
    workflow
  end

  def render("delete.json", %{workflow: workflow}) do
    workflow
  end

  def render(page, args) do
    %{page: page, args: args}
  end
end
