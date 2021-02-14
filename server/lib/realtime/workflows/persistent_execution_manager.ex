defmodule Realtime.Workflows.PersistentExecutionManager do

  def start_workflow_execution(workflow, execution, opts \\ []) do
    args = execution.arguments
    Realtime.Workflows.PersistentExecutionWorker.new(args)
    |> Oban.insert!()
  end
end
