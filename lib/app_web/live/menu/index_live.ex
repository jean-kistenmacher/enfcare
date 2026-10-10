defmodule AppWeb.MenuLive do
  use AppWeb, :live_view

  alias App.Accounts

  @impl true
	def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = Accounts.get_user_by_session_token(user_token)

    menu_default =
      if user.type == "managers" or user.superadmin do
        %{title: "Páginas", icon: "ki-element-11", submenus: [
          %{title: "Home", icon: "ki-home", link: "/", target: "_self"},
          %{title: "Protocolos", icon: "ki-book", link: "/protocolos", target: "_self"},
          %{title: "Avalie a plataforma", icon: "ki-chart-simple", link: "https://forms.gle/PinenuUTrPnmfTy46", target: "_blank"},
        ]}
      else
          %{title: "Páginas", icon: "ki-element-11", submenus: [
            %{title: "Home", icon: "ki-home", link: "/", target: "_self"},
            %{title: "Protocolos", icon: "ki-book", link: "/protocolos", target: "_self"},
            %{title: "Avalie a plataforma", icon: "ki-chart-simple", link: "https://forms.gle/PinenuUTrPnmfTy46", target: "_blank"},
          ]}
      end

    menu =
    if user.superadmin do
      [
        %{title: "Admin", icon: "ki-abstract-26", submenus: [
          %{title: "Usuários", icon: "ki-profile-user", link: "/user/users", target: "_self"},
          %{title: "Gerenciar Protocolos", icon: "ki-book", link: "/course/courses", target: "_self"},
        ]},
        menu_default
      ]
    else
      [
        menu_default
      ]
    end

    {:ok, assign(socket, current_user: user) |> assign(menu: menu)}
  end

  @impl true
  def render(assigns) do
    ~H"""
			<!--begin::Aside menu-->
      <div class="aside-menu flex-column-fluid">
        <!--begin::Aside Menu-->
        <div class="hover-scroll-overlay-y" data-kt-scroll="true" data-kt-scroll-activate="{default: false, lg: true}" data-kt-scroll-height="auto" data-kt-scroll-dependencies="#kt_aside_logo, #kt_aside_footer" data-kt-scroll-wrappers="#kt_aside_menu" data-kt-scroll-offset="0">
          <!--begin::Menu-->
          <div class="menu menu-column menu-title-gray-800 menu-state-title-primary menu-state-icon-primary menu-state-bullet-primary menu-arrow-gray-500" id="#kt_aside_menu" data-kt-menu="true">
            <!--begin:Menu item-->
            <%= for menu <- @menu do %>
            <div data-kt-menu-trigger="click" class="menu-item menu-accordion show">
              <!--begin:Menu link-->
              <span class="menu-link">
                <span class="menu-icon">
                  <i class={"#{menu.icon} ki-outline fs-2"}></i>
                </span>
                <span class="menu-title"><%= menu.title %></span>
                <span class="menu-arrow"></span>
              </span>
              <!--end:Menu link-->
              <%= for submenu <- menu.submenus do %>
                <!--begin:Menu sub-->
                <div class="menu-sub menu-sub-accordion">
                  <!--begin:Menu item-->
                  <div class="menu-item">
                    <!--begin:Menu link-->
                    <a class="menu-link" href={"#{submenu.link}"} target={"#{submenu.target}"} >
                    <span class="menu-icon">
                      <i class={"#{submenu.icon} ki-outline fs-2"}></i>
                    </span>
                      <span class="menu-title"><%= submenu.title %></span>
                    </a>
                    <!--end:Menu link-->
                  </div>
                  <!--end:Menu item-->
                </div>
                <!--end:Menu sub-->
              <%= end %>
            </div>
            <!--end:Menu item-->
            <%= end %>
          </div>
          <!--end::Menu-->
        </div>
      </div>
      <!--end::Aside menu-->
		"""
  end
end
