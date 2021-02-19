defmodule Realtime.Workflows.TransientExecutionManager do

  alias StateMachine.Interpreter
  require Logger

  def start_workflow_execution(workflow, execution, opts \\ []) do
    Task.Supervisor.start_child(
      __MODULE__,
      fn () ->
        Interpreter.start_execution(workflow, execution, opts)
      end
    )
  end
end
