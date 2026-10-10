defmodule App.Repo.Migrations.AddPositionToCourses do
  use Ecto.Migration

  def up do
    alter table(:courses) do
      add :position, :integer, null: false, default: 0
    end

    # Preserva a ordem atual (data, depois id) nos cursos já cadastrados.
    execute("""
    UPDATE courses
    SET position = ranked.rn
    FROM (
      SELECT id, ROW_NUMBER() OVER (ORDER BY "date", id) AS rn
      FROM courses
    ) AS ranked
    WHERE courses.id = ranked.id
    """)
  end

  def down do
    alter table(:courses) do
      remove :position
    end
  end
end
