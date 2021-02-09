defmodule Realtime.Workflows.Workflow do
  use Ecto.Schema

  alias Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @derive {Phoenix.Param, key: :id}

  schema "workflows" do
    field :name, :string
    field :trigger, :string
    field :definition, :map

    timestamps()

    has_many :executions, Realtime.Workflows.Execution
  end

  @doc false
  def changeset(workflow, params \\ %{}) do
    workflow
    |> Changeset.cast(params, [:name, :trigger, :definition])
    |> Changeset.validate_required([:name, :trigger, :definition])
    |> Changeset.validate_length(:name, min: 5)
    |> Changeset.unique_constraint(:name)
  end
end
