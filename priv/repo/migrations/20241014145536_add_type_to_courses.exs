defmodule App.Repo.Migrations.AddTypeToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :type, :string, default: "user"
    end
  end
end
