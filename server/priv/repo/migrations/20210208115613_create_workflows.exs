defmodule Realtime.Repo.Migrations.CreateWorkflows do
  use Ecto.Migration

  def change do
    create table(:workflows, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :trigger, :string
      add :definition, :map

      timestamps()
    end

    create unique_index(:workflows, [:name])

    create table(:executions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, references(:workflows, type: :uuid, on_delete: :delete_all)
      add :arguments, :map
      add :is_persistent, :boolean
      add :has_logs, :boolean

      timestamps()
    end
  end
end
