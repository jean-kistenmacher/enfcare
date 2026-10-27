defmodule App.Courses.GameAttempt do
  @moduledoc """
  Tentativa (única por aluno) de uma atividade gamificada de um módulo.

  `state` guarda o andamento do jogo (ver `App.CourseGame`). `points`, `level`,
  `effectiveness` e `safety` são preenchidos ao finalizar e servem de base para o
  ranking da plataforma, que deve considerar apenas `status` diferente de `playing`.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "course_game_attempts" do
    field :key, :string
    field :status, :string, default: "playing"
    field :state, :map, default: %{}
    field :points, :integer, default: 0
    field :level, :string
    field :effectiveness, :integer
    field :safety, :integer
    field :finished_at, :utc_datetime

    belongs_to :user, App.Accounts.User
    belongs_to :course, App.Courses.Course

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(attempt, attrs) do
    attempt
    |> cast(attrs, [
      :user_id,
      :course_id,
      :key,
      :status,
      :state,
      :points,
      :level,
      :effectiveness,
      :safety,
      :finished_at
    ])
    |> validate_required([:user_id, :course_id, :key, :status, :state])
    |> validate_inclusion(:status, ["playing", "finished", "game_over"])
    |> assoc_constraint(:user)
    |> assoc_constraint(:course)
    |> unique_constraint([:user_id, :course_id, :key])
  end
end
