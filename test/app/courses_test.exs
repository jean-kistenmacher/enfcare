defmodule App.CoursesTest do
  use App.DataCase

  alias App.Courses

  describe "courses" do
    alias App.Courses.Course

    import App.CoursesFixtures

    @invalid_attrs %{date: nil, description: nil, image: nil, text: nil, title: nil, video: nil}

    test "list_courses/0 returns all courses" do
      course = course_fixture()
      assert Courses.list_courses() == [course]
    end

    test "get_course!/1 returns the course with given id" do
      course = course_fixture()
      assert Courses.get_course!(course.id) == course
    end

    test "create_course/1 with valid data creates a course" do
      valid_attrs = %{date: ~N[2024-06-19 23:40:00], description: "some description", image: "some image", text: "some text", title: "some title", video: "some video"}

      assert {:ok, %Course{} = course} = Courses.create_course(valid_attrs)
      assert course.date == ~N[2024-06-19 23:40:00]
      assert course.description == "some description"
      assert course.image == "some image"
      assert course.text == "some text"
      assert course.title == "some title"
      assert course.video == "some video"
    end

    test "create_course/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Courses.create_course(@invalid_attrs)
    end

    test "update_course/2 with valid data updates the course" do
      course = course_fixture()
      update_attrs = %{date: ~N[2024-06-20 23:40:00], description: "some updated description", image: "some updated image", text: "some updated text", title: "some updated title", video: "some updated video"}

      assert {:ok, %Course{} = course} = Courses.update_course(course, update_attrs)
      assert course.date == ~N[2024-06-20 23:40:00]
      assert course.description == "some updated description"
      assert course.image == "some updated image"
      assert course.text == "some updated text"
      assert course.title == "some updated title"
      assert course.video == "some updated video"
    end

    test "update_course/2 with invalid data returns error changeset" do
      course = course_fixture()
      assert {:error, %Ecto.Changeset{}} = Courses.update_course(course, @invalid_attrs)
      assert course == Courses.get_course!(course.id)
    end

    test "delete_course/1 deletes the course" do
      course = course_fixture()
      assert {:ok, %Course{}} = Courses.delete_course(course)
      assert_raise Ecto.NoResultsError, fn -> Courses.get_course!(course.id) end
    end

    test "change_course/1 returns a course changeset" do
      course = course_fixture()
      assert %Ecto.Changeset{} = Courses.change_course(course)
    end
  end

  describe "modules" do
    import App.AccountsFixtures
    import App.CoursesFixtures

    setup do
      m1 = course_fixture(%{title: "m1", position: 1})
      m2 = course_fixture(%{title: "m2", position: 2})
      m3 = course_fixture(%{title: "m3", position: 3})
      %{user: user_fixture(), m1: m1, m2: m2, m3: m3}
    end

    test "only the first module is unlocked for a new user", %{user: user, m1: m1, m2: m2} do
      assert [first, second, third] = Courses.list_modules_with_status(user)

      assert %{number: 1, unlocked?: true, completed?: false, requires: nil} = first
      assert first.course.id == m1.id
      assert %{number: 2, unlocked?: false} = second
      assert second.requires.id == m1.id
      assert second.course.id == m2.id
      assert %{number: 3, unlocked?: false} = third
    end

    test "modules are ordered by position", %{user: user, m1: m1, m2: m2, m3: m3} do
      {:ok, _} = Courses.update_course(m1, %{position: 3})
      {:ok, _} = Courses.update_course(m3, %{position: 1})

      ids = user |> Courses.list_modules_with_status() |> Enum.map(& &1.course.id)
      assert ids == [m3.id, m2.id, m1.id]
    end

    test "completing a module unlocks only the next one", %{user: user, m1: m1, m2: m2, m3: m3} do
      assert {:ok, _} = Courses.complete_course(user, m1)

      assert [%{completed?: true}, %{unlocked?: true}, %{unlocked?: false}] =
               Courses.list_modules_with_status(user)

      assert Courses.course_unlocked?(user, m2)
      refute Courses.course_unlocked?(user, m3)
    end

    test "completing a locked module is rejected", %{user: user, m2: m2} do
      assert {:error, :locked} = Courses.complete_course(user, m2)
      assert Courses.completed_course_ids(user.id) == MapSet.new()
    end

    test "completing the same module twice is harmless", %{user: user, m1: m1} do
      assert {:ok, _} = Courses.complete_course(user, m1)
      assert {:ok, _} = Courses.complete_course(user, m1)
      assert Courses.completed_course_ids(user.id) == MapSet.new([m1.id])
    end

    test "progress is per user", %{user: user, m1: m1, m2: m2} do
      other = user_fixture()
      {:ok, _} = Courses.complete_course(user, m1)

      assert Courses.course_unlocked?(user, m2)
      refute Courses.course_unlocked?(other, m2)
    end

    test "superadmins have every module unlocked" do
      admin = user_fixture(%{superadmin: true})
      assert Courses.list_modules_with_status(admin) |> Enum.all?(& &1.unlocked?)
    end

    test "get_module_with_status/2 returns nil for unknown modules", %{user: user} do
      assert Courses.get_module_with_status(user, -1) == nil
    end
  end
end
