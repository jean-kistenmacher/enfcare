defmodule AppWeb.LandingLive do
  use AppWeb, :live_view

	@impl true
	def mount(_params, _session, socket) do

    {:ok, socket}
  end

	@impl true
	def render(assigns) do
    ~H"""
		<style>
		.home-container {
			display: flex;
			flex-direction: column;
			align-items: center;
			gap: 32px;
			margin-top: 68px;
		}
		.home-title {
			font-size: 2rem;
			font-weight: 700;
			color: var(--topbar-blue, #2c69a8);
			margin-bottom: 12px;
		}
		.home-cards {
			display: flex;
			gap: 40px;
			flex-wrap: wrap;
			justify-content: flex-start;
			margin-top: 32px;
		}
		.home-card {
			background: #fff;
			border-radius: 18px;
			box-shadow: 0 4px 18px rgba(44, 105, 168, 0.1);
			width: 220px;
			height: 220px;
			display: flex;
			flex-direction: column;
			align-items: stretch;
			justify-content: flex-end;
			text-decoration: none;
			overflow: hidden;
			padding: 0;
			transition: box-shadow 0.18s, transform 0.12s;
			border: none;
		}
		.home-card:hover {
			box-shadow: 0 8px 32px rgba(44, 105, 168, 0.18);
			transform: translateY(-2px) scale(1.03);
		}
		.card-img {
			width: 100%;
			height: calc(100% - 48px);
			display: flex;
			align-items: stretch;
			justify-content: stretch;
			background: none;
			padding: 0;
		}
		.card-img img {
			width: 100%;
			height: 100%;
			object-fit: cover;
			border-radius: 18px 18px 0 0;
			display: block;
		}
		.card-label {
			width: 100%;
			background: #336699;
			color: #fff;
			font-size: 1.18rem;
			font-weight: 700;
			text-align: center;
			padding: 14px 0 10px 0;
			border-radius: 0 0 4px 4px;
			letter-spacing: 0.5px;
			min-height: 38px;
			display: flex;
			align-items: center;
			justify-content: center;
		}
		.educare-info {
			margin: 48px auto 0 auto;
			max-width: 700px;
			background: #fff;
			border-radius: 14px;
			box-shadow: 0 2px 12px rgba(44, 105, 168, 0.06);
			padding: 32px 28px 24px 28px;
			color: #234;
			font-size: 1.08rem;
			line-height: 1.7;
		}
		.educare-info h2 {
			color: #336699;
			font-size: 1.35rem;
			font-weight: 700;
			margin-top: 0;
			margin-bottom: 16px;
		}
		.educare-info p {
			margin-bottom: 16px;
		}
		@media (max-width: 600px) {
			.home-cards {
				flex-direction: column;
				gap: 18px;
				align-items: center;
			}
			.home-card {
				width: 90vw;
				max-width: 320px;
				height: 180px;
			}
			.card-img {
				height: calc(100% - 38px);
			}
			.card-img img {
				max-height: unset;
			}
		}
		@media (max-width: 700px) {
			.educare-info {
				padding: 18px 8vw 14px 8vw;
				font-size: 1rem;
			}
		}

		</style>

			<!--begin::Post-->
			<div class="d-flex flex-column flex-root">
			<!--begin::Header Section-->
			<div class="mb-0" id="home">
				<!--begin::Wrapper-->
				<div class="bgi-no-repeat bgi-size-contain bgi-position-x-center bgi-position-y-bottom landing-dark-bg">
					<!--begin::Header-->
					<div class="landing-header" data-kt-sticky="true" data-kt-sticky-name="landing-header" data-kt-sticky-offset="{default: '200px', lg: '300px'}">
						<!--begin::Container-->
						<div class="container">
							<!--begin::Wrapper-->
							<div class="d-flex align-items-center justify-content-between">
								<!--begin::Logo-->
								<div class="d-flex align-items-center flex-equal">
									<!--begin::Mobile menu toggle-->
									<button class="btn btn-icon btn-active-color-primary me-3 d-flex d-lg-none" id="kt_landing_menu_toggle">
										<i class="ki-outline ki-abstract-14 fs-2hx"></i>
									</button>
									<!--end::Mobile menu toggle-->
									<!--begin::Logo image-->
									<a href="landing.html">
										<span class="logo-text">EduCare</span>
									</a>
									<!--end::Logo image-->
								</div>
								<!--end::Logo-->
								<!--begin::Menu wrapper-->
								<div class="d-lg-block" id="kt_header_nav_wrapper">
									<div class="d-lg-block p-5 p-lg-0" data-kt-drawer="true" data-kt-drawer-name="landing-menu" data-kt-drawer-activate="{default: true, lg: false}" data-kt-drawer-overlay="true" data-kt-drawer-width="200px" data-kt-drawer-direction="start" data-kt-drawer-toggle="#kt_landing_menu_toggle" data-kt-swapper="true" data-kt-swapper-mode="prepend" data-kt-swapper-parent="{default: '#kt_body', lg: '#kt_header_nav_wrapper'}">
										<!--begin::Menu-->
										<%!-- <div class="menu menu-column flex-nowrap menu-rounded menu-lg-row menu-title-gray-600 menu-state-title-primary nav nav-flush fs-5 fw-semibold" id="kt_landing_menu">
											<!--begin::Menu item-->
											<div class="menu-item">
												<!--begin::Menu link-->
												<a class="menu-link nav-link active py-3 px-4 px-xxl-6" href="#kt_body" data-kt-scroll-toggle="true" data-kt-drawer-dismiss="true">Conteúdo Educacional</a>
												<!--end::Menu link-->
											</div>
											<!--end::Menu item-->
											<!--begin::Menu item-->
											<div class="menu-item">
												<!--begin::Menu link-->
												<a class="menu-link nav-link py-3 px-4 px-xxl-6" href="#how-it-works" data-kt-scroll-toggle="true" data-kt-drawer-dismiss="true">Meus Pontos</a>
												<!--end::Menu link-->
											</div>
											<!--end::Menu item-->
											<!--begin::Menu item-->
											<div class="menu-item">
												<!--begin::Menu link-->
												<a class="menu-link nav-link py-3 px-4 px-xxl-6" href="#achievements" data-kt-scroll-toggle="true" data-kt-drawer-dismiss="true">Plano de gerenciamento</a>
												<!--end::Menu link-->
											</div>
											<!--end::Menu item-->
											<!--begin::Menu item-->
											<div class="menu-item">
												<!--begin::Menu link-->
												<a class="menu-link nav-link py-3 px-4 px-xxl-6" href="#team" data-kt-scroll-toggle="true" data-kt-drawer-dismiss="true">Descarte Correto</a>
												<!--end::Menu link-->
											</div>
											<!--end::Menu item-->
											<!--begin::Menu item-->
											<div class="menu-item">
												<!--begin::Menu link-->
												<a class="menu-link nav-link py-3 px-4 px-xxl-6" href="#portfolio" data-kt-scroll-toggle="true" data-kt-drawer-dismiss="true">Dóris Pergunta</a>
												<!--end::Menu link-->
											</div>
											<!--end::Menu item-->
										</div> --%>
										<!--end::Menu-->
									</div>
								</div>
								<!--end::Menu wrapper-->
								<!--begin::Toolbar-->
								<div class="flex-equal text-end ms-1">
									<%!-- <a href="/auth/users/log_in" class="btn btn-success">Entrar</a> --%>
								</div>
								<!--end::Toolbar-->
							</div>
							<!--end::Wrapper-->
						</div>
						<!--end::Container-->
					</div>
					<!--end::Header-->
					<!--begin::Landing hero-->
					<div class="d-flex flex-column flex-center w-100 min-h-350px min-h-lg-500px px-9">
						<!--begin::Heading-->
						<div class="text-center mb-5 mb-lg-10 py-10 py-lg-20">
							<!--begin::Title-->
							<h1 class="text-white lh-base fw-bold fs-2x fs-lg-3x mb-15">Bem-vindo ao
							<span style="background: linear-gradient(to right, #12CE5D 0%, #FFD80C 100%);-webkit-background-clip: text;-webkit-text-fill-color: transparent;">
								<span id="kt_landing_hero_text">EduCare</span>
							</span></h1>
							<!--end::Title-->
							<p class="text-white fs-1 fw-semibold mb-8">O EduCare é uma plataforma inovadora desenvolvida para reunir, organizar e disponibilizar materiais de apoio voltados ao ensino e à aprendizagem em saúde. Nosso objetivo é facilitar o acesso a conteúdos de qualidade, promover a integração entre teoria e prática e estimular o desenvolvimento de competências essenciais para estudantes, profissionais e educadores da área da saúde.

								Aqui você encontra recursos didáticos, roteiros de atividades, materiais multimídia e ferramentas interativas que auxiliam no processo de aprendizagem, tornando-o mais dinâmico, colaborativo e alinhado às necessidades do mundo contemporâneo. O EduCare valoriza a construção coletiva do conhecimento, incentivando a troca de experiências e o compartilhamento de boas práticas entre seus usuários.

								Seja bem-vindo(a) à nossa comunidade! Explore, aprenda e contribua para transformar a educação em saúde.</p>

							<!--end::Action-->
						</div>
						<!--end::Heading-->
					</div>
					<!--end::Landing hero-->
				</div>
				<!--end::Wrapper-->
				<!--begin::Curve bottom-->
				<div class="landing-curve landing-dark-color mb-5 mb-lg-5">
				</div>
				<!--end::Curve bottom-->
			</div>

			<div style="display:flex; justify-content:center; width:100%;">
				<div class="home-cards" style="justify-content: center;">
					<a class="home-card" href="https://doris-pro-ambiente.fly.dev/auth/users/log_in">
						<div class="card-img">
							<img src="/images/residuo_care.jpeg" alt="ResíduoCare" />
						</div>
						<div class="card-label">ResíduoCare</div>
					</a>
					<a class="home-card" href="/auth/users/log_in">
						<div class="card-img">
							<img src="/images/enf_care.png" alt="EnfCare" />
						</div>
						<div class="card-label">EnfCare</div>
					</a>
				</div>
			</div>
			<!--end::Header Section-->
			<!--begin::Footer Section-->
			<div class="landing-footer">
				<!--begin::Container-->
				<div class="container">
					<!--begin::Wrapper-->
					<div class="d-flex flex-column flex-md-row align-items-center justify-content-between py-10">
						<!--begin::Logo-->
						<div class="mb-5 mb-md-0"></div>
						<!--end::Logo-->
						<!--begin::Copyright-->
						<div class="text-dark fw-semibold fs-6">2026 © EnfCare. All rights reserved.</div>
						<div class="mb-5 mb-md-0"></div>
						<!--end::Copyright-->
					</div>
					<!--end::Wrapper-->
				</div>
				<!--end::Container-->
			</div>
			<!--end::Footer Section-->
			<!--begin::Scrolltop-->
			<div id="kt_scrolltop" class="scrolltop" data-kt-scrolltop="true">
				<i class="ki-outline ki-arrow-up"></i>
			</div>
			<!--end::Scrolltop-->
		</div>
		"""
  end
end
