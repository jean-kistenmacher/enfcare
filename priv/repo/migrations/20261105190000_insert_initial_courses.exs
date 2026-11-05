defmodule App.Repo.Migrations.InsertInitialCourses do
  use Ecto.Migration

  def up do
    execute("""
    INSERT INTO courses (id, title, image, date, inserted_at, updated_at, type, pdf, form1, form2, position)
    VALUES
      (1, 'Resistência Antimicrobiana (RAM)', 'curso_1', '2026-10-10 19:58:23', '2026-10-10 19:58:23', '2026-10-10 19:58:23', 'user', '', '', '', 1),
      (2, 'Antibióticos na prática clínica', 'curso_2', '2026-10-10 19:59:55', '2026-10-10 19:59:55', '2026-10-10 19:59:55', 'user', '', '', '', 2),
      (3, 'Programa de Gerenciamento de Antimicrobianos (PGA)', 'curso_3', '2026-10-10 20:00:05', '2026-10-10 20:00:05', '2026-10-10 20:00:05', 'user', '', '', '', 3)
    ON CONFLICT (id) DO NOTHING
    """)

    execute("SELECT setval(pg_get_serial_sequence('courses', 'id'), (SELECT MAX(id) FROM courses))")
  end

  def down do
    execute("DELETE FROM courses WHERE id IN (1, 2, 3) AND image IN ('curso_1', 'curso_2', 'curso_3')")
  end
end
