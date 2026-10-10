defmodule App.Openai.OpenaiService do
  use HTTPoison.Base

  @timeout 60_000

  defp base_url do
    url = System.get_env("OPENAI_API_URL") || "https://api.openai.com/v1"
    url = if url == "" or url == nil, do: "https://api.openai.com/v1", else: url
    IO.puts("DEBUG: Using OpenAI URL: #{url}")
    url
  end

  defp api_key do
    key = System.get_env("OPENAI_API_KEY") || ""
    if key == "" do
      IO.puts("WARNING: OPENAI_API_KEY is not set!")
    else
      IO.puts("DEBUG: OPENAI_API_KEY is set (length: #{String.length(key)})")
    end
    key
  end

  # Funtion to create a completion of chat
  def chat_completion(messages, model \\ "gpt-4o") do
    headers = %{
      "Authorization" => "Bearer #{api_key()}",
      "Content-Type" => "application/json"
    }

    body =
      %{
        # gpt-3.5-turbo gpt-4
        "model" => model,
        "messages" => messages,
        "temperature" => 0.7,
        "max_tokens" => 800
      }
      |> Jason.encode!()

    case post("#{base_url()}/chat/completions", body, headers, recv_timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("choices")
        |> List.first()

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("OpenAI API Error (#{status_code}): #{body}")
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("HTTP Error: #{inspect(reason)}")
        nil
    end
  end

  def chat_completion_with_max_tokens(messages, max_tokens, model \\ "gpt-4o") do
    headers = %{
      "Authorization" => "Bearer #{api_key()}",
      "Content-Type" => "application/json"
    }

    body =
      %{
        # gpt-3.5-turbo gpt-4
        "model" => model,
        "messages" => messages,
        "temperature" => 0.7,
        "max_tokens" => max_tokens
      }
      |> Jason.encode!()

    case post("#{base_url()}/chat/completions", body, headers, recv_timeout: @timeout) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("choices")
        |> List.first()

      {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
        IO.puts("OpenAI API Error (#{status_code}): #{body}")
        nil

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("HTTP Error: #{inspect(reason)}")
        nil
    end
  end

  def text_to_speech(input_text, voice \\ "nova") do
    headers = %{
      "Authorization" => "Bearer #{api_key()}",
      "Content-Type" => "application/json"
    }

    body =
      %{
        "model" => "tts-1", # tts-1-hd or tts-1
        "input" => input_text,
        "speed" => 1.0,
        "voice" => voice
      }
      |> Jason.encode!()

    case post("#{base_url()}/audio/speech", body, headers, recv_timeout: @timeout) do
      {:ok, %HTTPoison.Response{body: audio_data, headers: _response_headers}} ->
        # Define o diretório onde o arquivo será salvo
        audio_dir = Path.join(:code.priv_dir(:app), "static/images")

        # Caminho do arquivo MP3
        file_path = Path.join(audio_dir, "speech.mp3")

        # Remove o arquivo existente, se houver
        if File.exists?(file_path) do
          File.rm!(file_path)
        end

        # Salva o novo arquivo de áudio
        File.write!(file_path, audio_data)
        IO.puts("Speech saved as speech.mp3")
        {:ok, file_path}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  # Funtion to create a completion of text
  def completions(prompt, model \\ "gpt-3.5-turbo-instruct") do
    headers = %{
      "Authorization" => "Bearer #{api_key()}",
      "Content-Type" => "application/json"
    }

    body =
      %{
        # gpt-3.5-turbo-instruct gpt-4-instruct
        "model" => model,
        "prompt" => prompt,
        "temperature" => 0.7
      }
      |> Jason.encode!()

    case post("#{base_url()}/completions", body, headers, recv_timeout: @timeout) do
      {:ok, %HTTPoison.Response{body: body}} ->
        body
        |> Jason.decode!()
        |> Map.get("choices")
        |> List.first()

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts("Error: #{inspect(reason)}")
    end
  end
end
