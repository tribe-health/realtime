defmodule Realtime.Workflows.ExecutionManager do

  require Logger

  alias Realtime.Workflows.TransientExecutionManager
  alias Realtime.Workflows.PersistentExecutionManager

  def start_workflow_execution(workflow, execution, opts \\ []) do
    execution_type = execution.execution_type || workflow.default_execution_type

    case execution_type do
      :persistent ->
        PersistentExecutionManager.start_workflow_execution(workflow, execution, opts)
        {:ok, execution}
      :transient ->
        TransientExecutionManager.start_workflow_execution(workflow, execution, opts)
        {:ok, execution}
      other ->
        Logger.error("Start workflow execution with invalid execution type #{inspect other}")
        {:error, execution}
    end
  end
end
