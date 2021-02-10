defmodule Realtime.Workflows.ExecutionManager do

  require Logger

  def start_workflow_execution(workflow, execution, opts \\ []) do
    Logger.debug("Starting workflow #{inspect workflow} execution #{inspect execution} with options #{inspect opts}")
    reply_to = Keyword.get(opts, :reply_to, nil)
    Task.start_link(
      fn () ->
        :timer.sleep(4_000)
        if reply_to != nil do
          send reply_to, {:ok, %{answer: 42}}
        end
      end
    )
  end
end
