defmodule App.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :title, :string
      add :description, :text
      add :text, :text
      add :image, :text
      add :video, :string
      add :date, :naive_datetime

      timestamps(type: :utc_datetime)
    end
  end
end
