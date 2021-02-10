defmodule RealtimeWeb.ExecutionController do
  use RealtimeWeb, :controller
  alias Realtime.Workflows

  require Logger

  action_fallback RealtimeWeb.ErrorController

  def index(conn, %{"workflow_id" => workflow_id}) do
    json(conn, [])
  end

  def create(conn, %{"workflow_id" => workflow_id, "arguments" => arguments}) do
    args = %{
      arguments: arguments,
      is_persistent: false,
      has_logs: false,
    }
    with {:ok, workflow} <- Workflows.get_workflow(workflow_id),
         {:ok, execution} <- Workflows.invoke_workflow(workflow, args, reply_to: self()) do
      receive do
        {:ok, response} ->
          json(conn, %{response: response})
        _ ->
          json(conn, %{message: "error"})
      after
        5_000 ->
          json(conn, %{message: "timeout"})
      end
    end
  end

  ## Private
end
