defmodule App.Openai.Bot do
  alias App.Openai.OpenaiService
  alias App.Utils


  @assistant %{
    name: "Dóris",
    description: "Assistente virtual de auxílio mp RoteiroCare.",
    objectives: """
      #{Utils.get_doc_text()}
    """
  }

  def execute(question_items, user_name, :complete) do
    convert_question_items_to_chat(question_items)
    |> execute(user_name)
  end

  defp execute(chat, user_name) do
    case OpenaiService.chat_completion_with_max_tokens(
           [
             %{
               role: "system",
               content: """
               Nome: #{@assistant.name}

               Nome do usuário: #{user_name}

               Descrição: #{@assistant.description}

               Objetivos: #{@assistant.objectives}



               Procure responder sempre com poucas palavras. No máximo 400 tokens!

               """
             }
           ] ++ chat,
           500
         ) do
      %{"message" => %{"content" => text}} ->
        case OpenaiService.text_to_speech(text) do
          {:ok, _file_path} ->
            {:ok, text}

          {:error, reason} ->
            IO.puts("Text-to-speech error: #{inspect(reason)}")
            {:ok, text}
        end

      nil ->
        {:error, "Failed to get response from OpenAI"}

      error ->
        {:error, "Unexpected response: #{inspect(error)}"}
    end
  end

  defp convert_question_items_to_chat(question_items) do
    question_items
    |> Enum.map(fn item ->
      case item.image == nil or item.image == "" do
        true ->
          %{
            role:
              if item.is_user do
                "user"
              else
                "assistant"
              end,
            content: item.message
          }

        _ ->
          %{
            role:
              if item.is_user do
                "user"
              else
                "assistant"
              end,
            content: [
              %{type: "text", text: item.message},
              %{type: "image_url", image_url: %{url: item.image}}
            ]
          }
      end
    end)
  end
end
