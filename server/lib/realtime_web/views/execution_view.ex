defmodule RealtimeWeb.ExecutionView do
  use RealtimeWeb, :view

  def render("index.json", %{executions: executions}) do
    %{
      executions: render_many(executions, RealtimeWeb.ExecutionView, "execution.json")
    }
  end

  def render("show.json", %{execution: execution}) do
    %{
      execution: render_one(execution, RealtimeWeb.ExecutionView, "execution.json")
    }
  end

  def render("result.json", %{execution: execution, result: result}) do
    %{
      execution: render_one(execution, RealtimeWeb.ExecutionView, "execution.json"),
      result: result,
    }
  end

  def render("error.json", %{execution: execution, error: error}) do
    %{
      execution: render_one(execution, RealtimeWeb.ExecutionView, "execution.json"),
      error: error
    }
  end

  def render("execution.json", %{execution: execution}) do
    %{
      id: execution.id,
      workflow_id: execution.workflow_id,
      arguments: execution.arguments,
      start_state: execution.start_state,
      log_type: execution.log_type,
      created_at: execution.inserted_at,
      updated_at: execution.updated_at
    }
  end
end
