defmodule RealtimeWeb.WorkflowView do
  use RealtimeWeb, :view

  def render("index.json", %{workflows: workflows}) do
    %{
      workflows: render_many(workflows, RealtimeWeb.WorkflowView, "workflow.json")
    }
  end

  def render("show.json", %{workflow: workflow}) do
    %{
      workflow: render_one(workflow, RealtimeWeb.WorkflowView, "workflow.json")
    }
  end

  def render("workflow.json", %{workflow: workflow}) do
    %{
      id: workflow.id,
      name: workflow.name,
      trigger: workflow.trigger,
      definition: workflow.definition,
      created_at: workflow.inserted_at,
      updated_at: workflow.updated_at
    }
  end
end
