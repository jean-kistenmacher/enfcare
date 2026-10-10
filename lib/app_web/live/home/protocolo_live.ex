defmodule AppWeb.ProtocoloLive do
  use AppWeb, :live_view

  alias App.Accounts
	alias App.Courses
	import App.Utils

	@impl true
	def mount(_params, session, socket) do
    user_token = Map.get(session, "user_token")
    user = Accounts.get_user_by_session_token(user_token)

		info_page = %{
			title: "Home",
			breadcrumb: []
		}
		courses_users = Courses.list_courses_by_type("user")

    {:ok, assign(socket, current_user: user) |> assign(info_page: info_page) |> assign(courses: courses_users)}
  end

	@impl true
	def render(assigns) do
    ~H"""
			<!--begin::Post-->
			<div>
				<%!-- <!--begin::Toolbar-->
				<div class="toolbar" id="kt_toolbar">
					<!--begin::Container-->
					<div id="kt_toolbar_container" class="container-fluid d-flex flex-stack">
						<!--begin::Page title-->
						<div data-kt-swapper="true" data-kt-swapper-mode="prepend" data-kt-swapper-parent="{default: '#kt_content_container', 'lg': '#kt_toolbar_container'}" class="page-title d-flex align-items-center me-3 flex-wrap lh-1">
							<!--begin::Title-->
							<h1 class="d-flex align-items-center text-gray-900 fw-bold my-1 fs-3"><%= @info_page.title %></h1>
							<!--end::Title-->
							<!--begin::Separator-->
							<span class="h-20px border-gray-200 border-start mx-4"></span>
							<!--end::Separator-->
							<!--begin::Breadcrumb-->
							<ul class="breadcrumb breadcrumb-separatorless fw-semibold fs-7 my-1">
								<%= for breadcrumb <- @info_page.breadcrumb do %>
									<%= if breadcrumb.link != "" do %>
										<li class="breadcrumb-item text-muted">
											<a href={"#{breadcrumb.link}"} class="text-muted text-hover-primary"><%= breadcrumb.title %></a>
										</li>
										<li class="breadcrumb-item">
											<span class="bullet bg-gray-300 w-5px h-2px"></span>
										</li>
									<%= else %>
										<li class="breadcrumb-item text-gray-900"><%= breadcrumb.title %></li>
									<%= end %>
								<%= end %>
							</ul>
							<!--end::Breadcrumb-->
						</div>
						<!--end::Page title-->
					</div>
					<!--end::Container-->
				</div> --%>
				<!--end::Toolbar-->
				<!--begin::Container-->
				<div id="kt_content_container" class="container-xxl">
					<!--begin::Home card-->
					<div class="card">
						<!--begin::Body-->
						<div class="card-body p-lg-20">
							<div class="d-flex flex-stack mb-5">
								<!--begin::Title-->
								<h3 class="text-gray-900">Protocolos</h3>
								<!--end::Title-->
							</div>
							<div class="mb-17">
								<!--begin::Row-->
								<div class="row g-10">
									<%= for course <- @courses do %>
										<div class="col-md-4">
											<!--begin::Feature post-->
											<div class="card-xl-stretch me-md-3">
												<!--begin::Image-->
												<%= if course.video do %>
													<a class="d-block bgi-no-repeat bgi-size-cover bgi-position-center card-rounded position-relative min-h-175px mb-5" style={"background-image:url('#{course.image}')"} href={"/show/#{course.id}"}>
														<img src="/images/media/svg/misc/video-play.svg"class="position-absolute top-50 start-50 translate-middle" alt="" />
													</a>
												<%= else %>
													<a class="d-block overlay" href={"/show/#{course.id}"}>
															<!--begin::Image-->
															<div class="overlay-wrapper bgi-no-repeat bgi-position-center bgi-size-cover card-rounded min-h-175px" style={"background-image:url('#{course.image}')"}></div>
															<!--end::Image-->
															<!--begin::Action-->
															<div class="overlay-layer card-rounded bg-dark bg-opacity-25">
																<i class="ki-outline ki-eye fs-2x text-white"></i>
															</div>
															<!--end::Action-->
														</a>
												<%= end %>

												<!--end::Image-->
												<!--begin::Body-->
												<div class="m-0">
													<!--begin::Title-->
													<a href={"/show/#{course.id}"} class="fs-4 text-gray-900 fw-bold text-hover-primary text-gray-900 lh-base"><%= course.title %></a>
													<!--end::Title-->
													<!--begin::Text-->
													<div class="fw-semibold fs-5 text-gray-600 text-gray-900 my-4"><%= course.description %></div>
													<!--end::Text-->
													<!--begin::Content-->
													<div class="fs-6 fw-bold">
														<!--begin::Date-->
														<span class="text-muted"><%= format_datetime_crud(course.date) %></span>
														<!--end::Date-->
													</div>
													<!--end::Content-->
												</div>
												<!--end::Body-->
											</div>
											<!--end::Feature post-->
										</div>
									<%= end %>
								</div>
								<!--end::Row-->
							</div>
							<!--end::Section-->
						</div>
						<!--end::Body-->
					</div>
					<!--end::Home card-->
				</div>
				<!--end::Container-->
			</div>
		"""
  end
end
