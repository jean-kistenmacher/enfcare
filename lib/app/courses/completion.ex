defmodule App.Courses.Completion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_completions" do
    belongs_to :user, App.Accounts.User
    belongs_to :course, App.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(completion, attrs) do
    completion
    |> cast(attrs, [:user_id, :course_id])
    |> validate_required([:user_id, :course_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:course)
    |> unique_constraint([:user_id, :course_id])
  end
end
