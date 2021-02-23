defmodule RealtimeWeb.WorkflowController do
  use RealtimeWeb, :controller
  alias Realtime.Workflows

  require Logger

  action_fallback RealtimeWeb.ErrorController

  def index(conn, _params) do
    workflows = Workflows.list_workflows()
    render(conn, "index.json", workflows: workflows)
  end

  def create(conn, params) do
    with {:ok, workflow} <- Workflows.create_workflow(params) do
      conn
      |> put_status(:created)
      |> render("show.json", workflow: workflow)
    end
  end

  def show(conn, %{"id" => workflow_id}) do
    with {:ok, workflow} <- Workflows.get_workflow(workflow_id) do
      conn
      |> put_status(:ok)
      |> render("show.json", workflow: workflow)
    end
  end

  def update(conn, %{"id" => workflow_id} = params) do
    with {:ok, workflow} <- Workflows.get_workflow(workflow_id),
         {:ok, updated_workflow} <- Workflows.update_workflow(workflow, params) do
      conn
      |> put_status(:ok)
      |> render("show.json", workflow: updated_workflow)
    end
  end

  def delete(conn, %{"id" => workflow_id}) do
    with {:ok, workflow} <- Workflows.get_workflow(workflow_id),
         {:ok, _} <- Workflows.delete_workflow(workflow) do
      conn
      |> put_status(:ok)
      |> render("show.json", workflow: workflow)
    end
  end
end
