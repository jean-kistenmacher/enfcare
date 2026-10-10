defmodule App.Repo.Migrations.CreateCourseCompletions do
  use Ecto.Migration

  def change do
    create table(:course_completions) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:course_completions, [:user_id, :course_id])
    create index(:course_completions, [:course_id])
  end
end
