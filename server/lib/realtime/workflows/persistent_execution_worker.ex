defmodule Realtime.Workflows.PersistentExecutionWorker do
  use Oban.Worker, queue: :workflow_interpreter

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    Logger.debug("Start worker #{args}")
    :ok
  end
end
