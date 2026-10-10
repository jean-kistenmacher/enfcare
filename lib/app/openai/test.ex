defmodule App.Openai.Test do
  alias App.Openai.OpenaiService

  @assistant %{
    name: "Dóris",
    prompt: """
      Você vai criar uma batria de 5 perguntas para um quiz com alternativas de A, B, C ou D sobre um tema específico.
      Vai sempre retornar 1 pergunta de cada vez.
      Vai informar se acertou e dar a resposta correta da pergunta anterior.
      Cada pergunta vale 10 pontos e uma resposta errada desconta 5 pontos.
      O usuário não pode ficar com pontos negativos.

      Use tags html para formatar o texto. E <br> para quebra de linha.

      Tema: Resíduos Hospitalares

      No final, você deve informar a pontuação final do usuário.
    """
  }

  def execute(chat) do
    %{"message" => %{"content" => text}} =
      OpenaiService.chat_completion(
        [
          %{
            role: "system",
            content: """
            #{@assistant.prompt}
            """
          }
        ] ++ chat,
        "gpt-4o"
      )

    text
  end
end
