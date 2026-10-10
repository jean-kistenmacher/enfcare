# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     App.Repo.insert!(%App.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

changeset = App.Accounts.User.changeset(%App.Accounts.User{}, %{
  name: "GUI",
  email: "gui@mail.com",
  password: "admin@12345678",
  superadmin: true
})

case App.Repo.insert_or_update(changeset) do
  {:ok, user} ->
    IO.puts "User created or updated successfully."

  {:error, changeset} ->
    IO.puts "Failed to create or update user: #{inspect(changeset)}"
end
