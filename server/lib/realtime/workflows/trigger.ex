defmodule Realtime.Workflows.Trigger do
  require Logger

  alias Realtime.Workflows.Manager
  alias Realtime.Workflows

  def notify(txn) do
    workflows = Manager.workflows_for_change(txn)

    args = %{
      arguments: txn,
      is_persistent: false,
      has_logs: false,
    }

    Logger.debug("Trigger: #{inspect workflows}")

    Enum.each(workflows, fn workflow ->
      Workflows.invoke_workflow(workflow, args)
    end)
  end
end
