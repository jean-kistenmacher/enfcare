defmodule App.CoursesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `App.Courses` context.
  """

  @doc """
  Generate a course.
  """
  def course_fixture(attrs \\ %{}) do
    {:ok, course} =
      attrs
      |> Enum.into(%{
        date: ~N[2024-06-19 23:40:00],
        description: "some description",
        image: "some image",
        text: "some text",
        title: "some title",
        video: "some video"
      })
      |> App.Courses.create_course()

    course
  end
end
