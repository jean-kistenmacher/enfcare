defmodule App.Repo.Migrations.CreateCourseGameAttempts do
  use Ecto.Migration

  def change do
    create table(:course_game_attempts) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :key, :string, null: false
      add :status, :string, null: false, default: "playing"
      add :state, :map, null: false, default: %{}
      add :points, :integer, null: false, default: 0
      add :level, :string
      add :effectiveness, :integer
      add :safety, :integer
      add :finished_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create unique_index(:course_game_attempts, [:user_id, :course_id, :key])
    create index(:course_game_attempts, [:course_id])
    create index(:course_game_attempts, [:status, :points])
  end
end
