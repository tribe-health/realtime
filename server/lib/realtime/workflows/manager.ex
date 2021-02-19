defmodule Realtime.Workflows.Manager do
  use GenServer
  require Logger

  alias Realtime.Adapters.Changes
  alias Realtime.TransactionFilter
  alias Realtime.Workflows

  defmodule State do
    defstruct [:state, :queue, :table]
  end

  @table_name :workflows_manager

  ## Manager API

  def start_link(config) do
    GenServer.start_link(__MODULE__, config, name: __MODULE__)
  end

  @doc """
  Send notification for txn to the workflow manager.
  """
  def notify(txn) do
    GenServer.cast(__MODULE__, {:notify, txn})
  end

  @doc """
  Return a list of workflows that can be triggered by change.
  """
  def workflows_for_change(txn) do
    # No need to call GenServer, we can lookup the table directly
    :ets.foldl(
      fn ({_, workflow}, acc) ->
        event = %{event: "*", relation: workflow.trigger}
        if TransactionFilter.matches?(event, txn) do
          [workflow | acc]
        else
          acc
        end
      end,
      [],
      @table_name
    )
  end

  @doc """
  Return the workflow with the given id, or nil if not found.
  """
  def workflow_by_id(id) do
    case :ets.lookup(@table_name, id) do
      [{_, workflow}] -> workflow
      [] -> nil
    end
  end

  ## GenServer Callbacks

  @impl true
  def init(config) do
    workflows = :ets.new(@table_name, [:named_table, :protected])
    state = %State {
      state: :init,
      queue: [],
      table: workflows
    }

    Task.start_link(fn () ->
      workflows = Workflows.list_workflows()
      GenServer.cast(__MODULE__, {:load_workflows, workflows})
    end)

    {:ok, state}
  end

  @impl true
  def handle_cast({:load_workflows, workflows}, %State{state: :init, queue: queue, table: table} = state) do
    Enum.each(workflows, fn workflow_data ->
      workflow = %{
        id: workflow_data.id,
        trigger: workflow_data.trigger,
        definition: workflow_data.definition
      }
      :ets.insert(table, {workflow.id, workflow})
    end)
    Enum.each(queue, fn txn -> do_handle_notification(table, txn) end)
    new_state = %State{state | state: :sync, queue: []}
    {:noreply, new_state}
  end

  def handle_cast({:notify, txn}, %State{state: :init, queue: queue} = state) do
    # still loading up initial data, add txn to queue
    new_state = %State{state | queue: [txn | queue]}
    {:noreply, new_state}
  end

  def handle_cast({:notify, txn}, %State{table: table} = state) do
    do_handle_notification(table, txn)
    {:noreply, state}
  end

  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end

  ## Private

  defp do_handle_notification(table, txn) do
    for change <- txn.changes do
      case change_type(change) do
        :insert -> insert_workflow(table, change)
        :update -> update_workflow(table, change)
        :delete -> delete_workflow(table, change)
        _ -> nil
      end
    end
  end

  defp insert_workflow(table, %Changes.NewRecord{record: record} = _change) do
    do_insert_workflow(table, record)
  end

  defp update_workflow(table, %Changes.UpdatedRecord{record: record} = _change) do
    do_insert_workflow(table, record)
  end

  defp delete_workflow(table, %Changes.DeletedRecord{old_record: record} = _change) do
    :ets.delete(table, record["id"])
  end

  defp do_insert_workflow(table, record) do
    workflow = %{
      id: record["id"],
      trigger: record["trigger"],
      definition: record["definition"]
    }
    :ets.insert(table, {workflow.id, workflow})
  end

  defp change_type(change) do
    if change.schema == "public" and change.table == "workflows" do
      case change.type do
        "INSERT" -> :insert
        "UPDATE" -> :update
        "DELETE" -> :delete
        _ -> :other
      end
    else
        :other
    end
  end
end
