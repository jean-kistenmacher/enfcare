defmodule App.Repo.Migrations.AddPdfForm1Form2CoursesTable do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :pdf, :text, default: ""
      add :form1, :text, default: ""
      add :form2, :text, default: ""
    end
  end
end
