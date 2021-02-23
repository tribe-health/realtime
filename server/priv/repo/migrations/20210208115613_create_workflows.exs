defmodule Realtime.Repo.Migrations.CreateWorkflows do
  use Ecto.Migration

  def change do
    create table(:workflows, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string
      add :trigger, :string
      add :definition, :map
      add :default_execution_type, :string
      add :default_log_type, :string

      timestamps()
    end

    create unique_index(:workflows, [:name])

    create table(:executions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :workflow_id, references(:workflows, type: :uuid, on_delete: :delete_all)

      add :start_state, :string
      add :arguments, :map
      add :execution_type, :string
      add :log_type, :string

      timestamps()
    end
  end
end
