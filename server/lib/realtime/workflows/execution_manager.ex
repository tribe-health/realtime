defmodule Realtime.Workflows.ExecutionManager do

  require Logger

  alias Realtime.Workflows.TransientExecutionManager
  alias Realtime.Workflows.PersistentExecutionManager

  def start_workflow_execution(workflow, execution, opts \\ []) do
    if execution.is_persistent do
      PersistentExecutionManager.start_workflow_execution(workflow, execution, opts)
    else
      TransientExecutionManager.start_workflow_execution(workflow, execution, opts)
    end
  end
end
