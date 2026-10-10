defmodule AppWeb.Course.CourseLive.FormComponent do
  use AppWeb, :live_component

  alias App.Courses

  @impl true
  def render(assigns) do
    ~H"""
    <div>
    <style>
      .form-container {
        max-height: 700px; /* Ajuste a altura conforme necessário */
        overflow-y: auto;
      }
    </style>
      <.header>
        <%= @title %>
        <:subtitle>Formulário de cadastro</:subtitle>
      </.header>

      <div class="form-container">
        <.simple_form
          for={@form}
          id="course-form"
          phx-target={@myself}
          phx-submit="save"
          phx-change="validate"
        >
          <.input field={@form[:title]} type="text" label="Título" />
          <.input field={@form[:description]} type="text" label="Descrição" />
          <.input field={@form[:position]} type="number" min="0" label="Ordem do módulo (menor número aparece primeiro; o módulo seguinte só é liberado após concluir o anterior)" />
            <label class={"fs-6 fw-semibold mb-2 mt-4"}>PDF</label>
            <.live_file_input upload={@uploads.pdf_file} class="form-control bg-transparent mb-2" />
            <.input field={@form[:pdf]} type="hidden" label="" />
          <.input field={@form[:form1]} type="text" label="Formulário 1" />
          <.input field={@form[:form2]} type="text" label="Formulário 2" />
          <.input field={@form[:text]} type="textarea" label="Texto" />
          <label class={"fs-6 fw-semibold mb-2 mt-4"}>Imagem</label>
          <.live_file_input upload={@uploads.avatar} class="form-control bg-transparent mb-2" />
          <.input field={@form[:image]} type="hidden" label="" />
          <.input field={@form[:video]} type="text" label="Vídeo (Só o código. Ex.: https://www.youtube.com/watch?v=ypnqB7XR26Q => Código = ypnqB7XR26Q)" />
          <.input field={@form[:date]} type="datetime-local" label="Data" />
          <:actions>
            <.button phx-disable-with="Salvando...">Salvar</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
  end

  @impl true
  def update(%{course: course} = assigns, socket) do
    changeset = Courses.change_course(course)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)
     |> assign(:image_default, course.image)
     |> assign(:pdf_default, course.pdf)
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png), max_entries: 1)
     |> allow_upload(:pdf_file, accept: ~w(.pdf), max_entries: 1)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"course" => course_params}, socket) do
    changeset =
      socket.assigns.course
      |> Courses.change_course(course_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"course" => course_params}, socket) do
    save_course(socket, socket.assigns.action, course_params)
  end

  defp save_course(socket, :edit, course_params) do
    socket.assigns.uploads
    [image_base64] =
      case Phoenix.LiveView.consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        image = File.read!(path)
        File.rm!(path)
        encoded_image = Base.encode64(image)
        "data:image/jpeg;base64," <> encoded_image
      end) do
        [] -> [""]
        res -> res
      end

    [pdf_base64] =
      case Phoenix.LiveView.consume_uploaded_entries(socket, :pdf_file, fn %{path: path}, _entry ->
        pdf = File.read!(path)
        File.rm!(path)
        encoded_pdf = Base.encode64(pdf)
        "data:application/pdf;base64," <> encoded_pdf
      end) do
        [] -> [""]
        res -> res
      end

    course_params =
      if image_base64 !== "" do
        Map.put(course_params, "image", image_base64)
      else
        Map.put(course_params, "image", socket.assigns.image_default)
      end

    course_params =
      if pdf_base64 !== "" do
        Map.put(course_params, "pdf", pdf_base64)
      else
        Map.put(course_params, "pdf", socket.assigns.pdf_default)
      end

    case Courses.update_course(socket.assigns.course, course_params) do
      {:ok, course} ->
        notify_parent({:saved, course})

        {:noreply,
         socket
         |> put_flash(:info, "Course updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_course(socket, :new, course_params) do
    [image_base64] =
      case consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        image = File.read!(path)
        File.rm!(path)
        encoded_image = Base.encode64(image)
        "data:image/jpeg;base64," <> encoded_image
      end) do
        [] -> [""]
        res -> res
      end

    [pdf_base64] =
      case consume_uploaded_entries(socket, :pdf_file, fn %{path: path}, _entry ->
        pdf = File.read!(path)
        File.rm!(path)
        encoded_pdf = Base.encode64(pdf)
        "data:application/pdf;base64," <> encoded_pdf
      end) do
        [] -> [""]
        res -> res
      end

    course_params = Map.put(course_params, "image", image_base64)

    course_params =
      if pdf_base64 !== "" do
        Map.put(course_params, "pdf", pdf_base64)
      else
        course_params
      end

    case Courses.create_course(course_params) do
      {:ok, course} ->
        notify_parent({:saved, course})

        {:noreply,
         socket
         |> put_flash(:info, "Course created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
