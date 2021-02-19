defmodule Realtime.Workflows.PersistentExecutionManager do

  def start_workflow_execution(workflow, execution, opts \\ []) do
    args = %{
      arguments: execution.arguments,
      workflow_id: workflow.id,
      execution_id: execution.id
    }
    Realtime.Workflows.PersistentExecutionWorker.new(args)
    |> Oban.insert!()
  end
end
