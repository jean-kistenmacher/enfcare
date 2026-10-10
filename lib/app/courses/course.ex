defmodule App.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :date, :naive_datetime
    field :description, :string
    field :image, :string
    field :text, :string
    field :title, :string
    field :video, :string
    field :type, :string, default: "user"
    field :pdf, :string, default: ""
    field :form1, :string, default: ""
    field :form2, :string, default: ""
    field :position, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:title, :description, :text, :image, :video, :date, :pdf, :form1, :form2, :position])
    |> validate_required([:title, :description, :image, :date, :position], message: "Este campo é obrigatório")
    |> validate_number(:position, greater_than_or_equal_to: 0)
  end
end
