defmodule App.Courses do
  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Courses.Course
  alias App.Courses.Completion

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
    Retrieves a list of courses ordered by the course ID in descending order.

    ## Examples

        iex> App.Courses.list_courses_by_order()
        [%Course{...}, %Course{...}, ...]

    """
    def list_courses_by_order do
      Repo.all(from c in Course, order_by: [desc: c.id])
    end

    @doc """
    Retrieves a list of courses ordered by the course date in descending order.

    ## Examples

        iex> App.Courses.list_courses_by_order_site()
        [%Course{...}, %Course{...}, ...]

    """
    def list_courses_by_order_site do
      Repo.all(from c in Course, order_by: [desc: c.date])
    end

    def list_courses_by_type(type) do
      Repo.all(from c in Course, where: c.type == ^type, order_by: [asc: c.date])
    end

    @doc """
    Retrieves a list of courses based on the given limit and order.

    ## Parameters

      * `limit` - The maximum number of courses to retrieve.
      * `order` - The order in which the courses should be retrieved. Can be "asc" or any other value.

    ## Examples

        iex> App.Courses.get_courses(10, "asc")
        [%Course{...}, %Course{...}, ...]

    """
    def get_courses(limit, order) do
      case order do
        "asc" -> Repo.all(from c in Course, limit: ^limit, order_by: [asc: c.id])
        _ -> Repo.all(from c in Course, limit: ^limit, order_by: [desc: c.id])
      end
    end

    def get_courses_by_type(limit, order, type) do
      case order do
        "asc" -> Repo.all(from c in Course, where: c.type == ^type, limit: ^limit, order_by: [asc: c.id])
        _ -> Repo.all(from c in Course, where: c.type == ^type, limit: ^limit, order_by: [desc: c.id])
      end
    end

    @doc """
    Retrieves a list of random courses based on the given limit.

    ## Parameters

      * `limit` - The maximum number of courses to retrieve.

    ## Examples

        iex> App.Courses.get_random_courses(5)
        [%Course{...}, %Course{...}, ...]

    """
    def get_random_courses(limit) do
      from(c in Course, limit: ^limit, order_by: [asc: fragment("RANDOM()")])
      |> Repo.all()
    end

    def get_random_courses_by_type(limit, type) do
      from(c in Course, where: c.type == ^type, limit: ^limit, order_by: [asc: fragment("RANDOM()")])
      |> Repo.all()
    end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  def get_course_by_type!(id, type) do
    Repo.get_by!(Course, id: id, type: type)
  end

  @doc """
  Creates a course.

  ## Examples

      iex> create_course(%{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{data: %Course{}}

  """
  def change_course(%Course{} = course, attrs \\ %{}) do
    Course.changeset(course, attrs)
  end

  @doc """
  Lists the modules the user can see, in display order, with their status.

  Each item is `%{course: course, number: n, completed?: bool, unlocked?: bool, requires: course | nil}`.
  A module is unlocked when it is the first one or the previous module was
  completed by the user. Superadmins and managers see every module unlocked.
  """
  def list_modules_with_status(user) do
    privileged? = user.superadmin or user.type == "managers"
    modules = if privileged?, do: list_modules(), else: list_modules_by_type(user.type)
    completed = completed_course_ids(user.id)

    {items, _previous} =
      modules
      |> Enum.with_index(1)
      |> Enum.map_reduce(nil, fn {course, number}, previous ->
        item = %{
          course: course,
          number: number,
          completed?: MapSet.member?(completed, course.id),
          unlocked?: privileged? or previous == nil or previous.completed?,
          requires: previous && previous.course
        }

        {item, item}
      end)

    items
  end

  @doc """
  Returns the status item (see `list_modules_with_status/1`) for a single
  module, or `nil` when the user cannot see it.
  """
  def get_module_with_status(user, course_id) do
    user
    |> list_modules_with_status()
    |> Enum.find(&(&1.course.id == course_id))
  end

  def course_unlocked?(user, %Course{id: course_id}) do
    case get_module_with_status(user, course_id) do
      %{unlocked?: unlocked?} -> unlocked?
      nil -> false
    end
  end

  @doc """
  Marks a course as completed by the user, which unlocks the next module.

  Returns `{:error, :locked}` when the user has no access to the course yet.
  Completing an already completed course is a no-op.
  """
  def complete_course(user, %Course{} = course) do
    if course_unlocked?(user, course) do
      %Completion{}
      |> Completion.changeset(%{user_id: user.id, course_id: course.id})
      |> Repo.insert(on_conflict: :nothing, conflict_target: [:user_id, :course_id])
    else
      {:error, :locked}
    end
  end

  def completed_course_ids(user_id) do
    from(c in Completion, where: c.user_id == ^user_id, select: c.course_id)
    |> Repo.all()
    |> MapSet.new()
  end

  defp list_modules do
    Repo.all(from c in Course, order_by: [asc: c.position, asc: c.id])
  end

  defp list_modules_by_type(type) do
    Repo.all(from c in Course, where: c.type == ^type, order_by: [asc: c.position, asc: c.id])
  end
end
