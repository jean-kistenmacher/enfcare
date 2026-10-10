defmodule App.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
    Retrieves a list of users ordered by the user ID in descending order.

    ## Examples

        iex> App.Users.list_users_by_order()
        [%User{...}, %User{...}, ...]

    """
    def list_users_by_order do
      Repo.all(from c in User, order_by: [desc: c.id])
    end

    @doc """
    Retrieves a list of users ordered by the user date in descending order.

    ## Examples

        iex> App.Users.list_users_by_order_site()
        [%User{...}, %User{...}, ...]

    """
    def list_users_by_order_site do
      Repo.all(from c in User, order_by: [desc: c.date])
    end

    @doc """
    Retrieves a list of users based on the given limit and order.

    ## Parameters

      * `limit` - The maximum number of users to retrieve.
      * `order` - The order in which the users should be retrieved. Can be "asc" or any other value.

    ## Examples

        iex> App.Users.get_users(10, "asc")
        [%User{...}, %User{...}, ...]

    """
    def get_users(limit, order) do
      case order do
        "asc" -> Repo.all(from c in User, limit: ^limit, order_by: [asc: c.id])
        _ -> Repo.all(from c in User, limit: ^limit, order_by: [desc: c.id])
      end
    end

    @doc """
    Retrieves a list of random users based on the given limit.

    ## Parameters

      * `limit` - The maximum number of users to retrieve.

    ## Examples

        iex> App.Users.get_random_users(5)
        [%User{...}, %User{...}, ...]

    """
    def get_random_users(limit) do
      from(c in User, limit: ^limit, order_by: [asc: fragment("RANDOM()")])
      |> Repo.all()
    end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset_default(user, attrs)
  end
end
