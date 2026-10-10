defmodule AppWeb.Chat.ChatLive.Index do
  use AppWeb, :live_view

  alias App.Chats
  import App.Utils

  @impl true
  def mount(_params, session, socket) do
    user = App.Accounts.get_user_by_session_token(Map.get(session, "user_token"))
    chats = Chats.list_chats_by_user(user.id)
    socket = push_event(socket, "scroll_to_bottom", %{})

    {:ok,
     assign(socket, :chats, chats)
     |> assign(:user, user)
     |> assign(:audio_path, "")
     |> assign(:message, "")
     |> assign(:uploaded_files, [])
     |> assign(doris_image: "/images/doris_neutra.png")
     |> allow_upload(:avatar, accept: ~w(.jpg .jpeg .png .webp), max_entries: 1)}
  end

  @impl true
  def handle_event(
        "send_message",
        %{"message" => message},
        socket
      ) do
    user = socket.assigns.user

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

    case Chats.create_chat(%{
           user_id: user.id,
           is_user: true,
           message: message,
           image: image_base64
         }) do
      {:ok, _} ->
        chats = Chats.list_chats_by_user(user.id)

        send(self(), {:generate_text, chats})
        socket = push_event(socket, "scroll_to_bottom", %{})
         audio_path = ""
        {:noreply, socket |> assign(:chats, chats) |> assign(:message, "") |> assign(:audio_path, audio_path)}

      {:error, error} ->
        IO.inspect(error)
        {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:generate_text, _chats}, socket) do
    chats = Chats.list_chats_by_user_last_seven(socket.assigns.user.id)

    case App.Openai.Bot.execute(chats, socket.assigns.user.name, :complete) do
      {:ok, text} ->
        # Define o novo caminho do áudio
        audio_path = "/images/speech.mp3"

        imagens_doris = [
          "/images/doris_atencao.png",
          "/images/doris_alegria.png",
          "/images/doris_duvida.png",
          "/images/doris_neutra.png"
        ]

        imagem_randomica = Enum.random(imagens_doris)

        case Chats.create_chat(%{
               user_id: socket.assigns.user.id,
               is_user: false,
               message: text
             }) do
          {:ok, _} ->
            chats = Chats.list_chats_by_user(socket.assigns.user.id)
            socket = push_event(socket, "scroll_to_bottom", %{})

            socket =
              assign(socket,
                message: "",
                chats: chats,
                audio_path: audio_path,
                doris_image: imagem_randomica
              )

            {:noreply, push_event(socket, "play_audio", %{})}

          {:error, error} ->
            IO.inspect(error)
            {:noreply, socket}
        end

      {:error, error} ->
        IO.puts("Bot error: #{inspect(error)}")
        {:noreply, socket}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate", %{"message" => message}, socket) do
    {:noreply, socket |> assign(:message, message) |> assign(:audio_path, "")}
  end

  @impl true
  def handle_event(
        "clear_chat",
        %{},
        socket
      ) do
    user = socket.assigns.user
    Chats.clear_chat(user.id)
    {:noreply, socket |> assign(:chats, []) |> assign(:audio_path, "")}
  end
end
