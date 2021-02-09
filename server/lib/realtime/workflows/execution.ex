defmodule Realtime.Workflows.Execution do
  use Ecto.Schema

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @derive {Phoenix.Param, key: :id}

  schema "executions" do
    field :arguments, :map
    field :is_persistent, :boolean
    field :has_logs, :boolean

    timestamps()

    belongs_to :workflow, Realtime.Workflows.Workflow, type: Ecto.UUID
  end
end
