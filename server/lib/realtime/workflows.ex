defmodule Realtime.Workflows do
  @moduledoc """
  The Workflows context.
  """

  import Ecto.Query, warn: false
  alias Realtime.Repo

  alias Realtime.Workflows.Execution
  alias Realtime.Workflows.Workflow
  alias Realtime.Workflows.ExecutionManager

  @doc """
  Returns the list of workflows.
  """
  def list_workflows do
    Repo.all(Workflow)
  end

  @doc """
  Creates a workflow.
  """
  def create_workflow(attrs \\ %{}) do
    %Workflow{}
    |> Workflow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the workflow with the given id.
  """
  def get_workflow(id) do
    Workflow
    |> get_or_not_found(id)
  end

  @doc """
  Updates the given workflow.
  """
  def update_workflow(workflow, attrs \\ %{}) do
    workflow
    |> Workflow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes the given workflow.
  """
  def delete_workflow(workflow) do
    Repo.delete(workflow)
  end

  def invoke_workflow(workflow, attrs \\ %{}, opts \\ []) do
    with {:ok, execution} <- create_workflow_execution(workflow, attrs) do
      ExecutionManager.start_workflow_execution(workflow, execution, opts)
      {:ok, execution}
    end
  end

  def create_workflow_execution(workflow, attrs \\ %{}) do
    %Execution{}
    |> Execution.changeset(attrs)
    |> Execution.put_workflow(workflow)
    |> Repo.insert()
  end

  ## Private

  defp get_or_not_found(queryable, id, opts \\ []) do
    case Repo.get(queryable, id, opts) do
      nil -> {:not_found, id}
      found -> {:ok, found}
    end
  end
end
