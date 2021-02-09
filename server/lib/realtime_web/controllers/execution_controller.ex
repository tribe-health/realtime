defmodule RealtimeWeb.ExecutionController do
  use RealtimeWeb, :controller
  alias Realtime.Workflows

  require Logger

  action_fallback RealtimeWeb.ErrorController

  def index(conn, params) do
    Logger.debug("Nested #{inspect params}")
    render(conn, "index.json", executions: [])
  end
end
