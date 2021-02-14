defmodule Realtime.Workflows.TransientExecutionManager do

  def start_workflow_execution(workflow, execution, opts \\ []) do
    reply_to = Keyword.get(opts, :reply_to, nil)
    Task.Supervisor.start_child(
      __MODULE__,
      fn () ->
        :timer.sleep(4_000)
        if reply_to != nil do
          send reply_to, {:ok, %{answer: 42}}
        end
      end
    )
  end
end
