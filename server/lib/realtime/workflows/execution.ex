defmodule Realtime.Workflows.Execution do
  use Ecto.Schema

  alias Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @derive {Phoenix.Param, key: :id}

  schema "executions" do
    field :arguments, :map
    field :is_persistent, :boolean
    field :has_logs, :boolean

    timestamps()

    belongs_to :workflow, Realtime.Workflows.Workflow, type: Ecto.UUID
  end

  @doc false
  def changeset(execution, params \\ %{}) do
    execution
    |> Changeset.cast(params, [:arguments, :is_persistent, :has_logs])
    |> Changeset.validate_required([:arguments, :is_persistent, :has_logs])
  end

  @doc false
  def put_workflow(changeset, workflow) do
    changeset
    |> Changeset.change(%{workflow_id: workflow.id})
  end
end
