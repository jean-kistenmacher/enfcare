defmodule AppWeb.Auth.UserConfirmationLiveTest do
  use AppWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import App.AccountsFixtures

  alias App.Accounts
  alias App.Repo

  setup do
    %{user: user_fixture()}
  end

  describe "Confirm user" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/auth/users/confirm/some-token")
      assert html =~ "Confirm Account"
    end
  end
end
