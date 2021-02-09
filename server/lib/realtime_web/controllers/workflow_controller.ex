defmodule RealtimeWeb.WorkflowController do
  use RealtimeWeb, :controller
  alias Realtime.Workflows

  require Logger

  action_fallback RealtimeWeb.ErrorController

  def index(conn, _params) do
    workflows = Workflows.list_workflows()
    Logger.debug("Returning workflows #{inspect workflows}")
    render(conn, "index.json", workflows: workflows_json(workflows))
  end

  def create(conn, params) do
    with {:ok, workflow} <- Workflows.create_workflow(params) do
      conn
      |> put_status(:created)
      |> render("create.json", workflow: workflow_json(workflow))
    end
  end

  def update(conn, %{"id" => workflow_id} = params) do
    with {:ok, workflow} <- Workflows.get_workflow(workflow_id),
         {:ok, _} <- Workflows.update_workflow(workflow, params) do
      conn
      |> put_status(:ok)
      |> render("update.json", workflow: workflow_json(workflow))
    end
  end

  def delete(conn, %{"id" => workflow_id}) do
    with {:ok, workflow} <- Workflows.get_workflow(workflow_id),
         {:ok, _} <- Workflows.delete_workflow(workflow) do
      conn
      |> put_status(:ok)
      |> render("delete.json", workflow: workflow_json(workflow))
    end
  end

  defp workflows_json(workflows), do: workflows |> Enum.map(&workflow_json(&1))

  defp workflow_json(workflow) do
    %{
      id: workflow.id,
      name: workflow.name,
      trigger: workflow.trigger,
      definition: workflow.definition
    }
  end
end
