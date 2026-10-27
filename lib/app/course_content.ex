defmodule App.CourseContent do
  @moduledoc """
  Conteúdo (seções e blocos) das páginas de andamento dos cursos/módulos.

  Cada curso é identificado pelo número do módulo (posição na lista de módulos)
  e possui `sections`, exibidas no aside da página. Cada seção possui `blocks`,
  renderizados em ordem pela página:

    * `{:paragraph, html}` - parágrafo (HTML estático confiável)
    * `{:subtitle, text}` - subtítulo dentro da seção
    * `{:figure, file, caption}` - figura em `priv/static/images/cursos/curso_N/`
    * `{:figure, file, caption, source}` - figura com fonte diferente da padrão
    * `{:list, title | nil, items}` - lista com marcadores
    * `{:intro_list, html, items}` - lista precedida por um parágrafo de introdução
    * `{:table, header, rows}` - tabela (`header` e cada linha são listas de textos)
    * `{:callout, label, text}` - destaque (ex.: conceito-chave)
    * `{:cards, [%{title: t, intro: i, items: [..]}]}` - quadros lado a lado (`intro` é opcional)
    * `{:reflection, key, prompt}` - campo de autorreflexão
    * `{:references, [html]}` - lista de referências bibliográficas
    * `{:quiz, key, questions, closing}` - questões de múltipla escolha, respondidas
      uma por vez; `closing` são os parágrafos exibidos ao final da avaliação
    * `{:game, key}` - atividade gamificada (ver `App.CourseGame`), obrigatória para
      concluir o módulo
  """

  @source "Fonte: uso da ferramenta chat GPT para criação da imagem."

  @doc "Retorna o curso do módulo `number` ou `nil` se ainda não possui conteúdo."
  def get(1), do: course_1()
  def get(2), do: course_2()
  def get(_number), do: nil

  @doc "Caminho da página de andamento do módulo, ou do conteúdo legado quando não há conteúdo."
  def start_path(%{number: number, course: course}) do
    if get(number), do: "/cursos/#{course.id}", else: "/show/#{course.id}"
  end

  @doc "Caminho público de uma figura do curso."
  def figure_path(number, file), do: "/images/cursos/curso_#{number}/#{file}"

  @doc "Fonte padrão das figuras."
  def source, do: @source

  @doc "Procura a seção pelo `slug`; cai na primeira seção quando não encontrada."
  def find_section(course, slug) do
    Enum.find(course.sections, hd(course.sections), &(&1.slug == slug))
  end

  @doc "Retorna os quizzes do curso como `[{key, questions}]`."
  def quizzes(course) do
    for section <- course.sections, {:quiz, key, questions, _closing} <- section.blocks do
      {key, questions}
    end
  end

  @doc "Retorna as chaves das atividades gamificadas do curso."
  def games(course) do
    for section <- course.sections, {:game, key} <- section.blocks, do: key
  end

  @doc "Retorna as questões do quiz `key` do curso, ou `[]` quando não existir."
  def quiz_questions(course, key) do
    Enum.find_value(quizzes(course), [], fn {k, questions} -> k == key && questions end)
  end

  @doc "Retorna a seção seguinte à de `slug`, ou `nil` quando for a última."
  def next_section(course, slug) do
    course.sections
    |> Enum.drop_while(&(&1.slug != slug))
    |> Enum.at(1)
  end

  @doc "Retorna a seção anterior à de `slug`, ou `nil` quando for a primeira."
  def previous_section(course, slug) do
    course.sections
    |> Enum.take_while(&(&1.slug != slug))
    |> List.last()
  end

  defp course_1 do
    %{
      number: 1,
      title: "Curso 1",
      subtitle: "Resistência Antimicrobiana (RAM)",
      sections: [
        %{
          slug: "introducao",
          title: "Introdução e Problematização",
          heading: "Introdução",
          blocks: [
            {:paragraph,
             "A RAM configura-se atualmente como uma emergência global de saúde pública, sendo reconhecida pela Organização Mundial da Saúde (OMS) como uma das dez principais ameaças à saúde mundial. Esse fenômeno ocorre quando microrganismos desenvolvem mecanismos capazes de sobreviver à ação dos antimicrobianos, tornando infecções comuns progressivamente mais difíceis de tratar. Estima-se que, em 2019, aproximadamente 4,95 milhões de mortes estiveram associadas à RAM em nível global, sendo 1,27 milhão diretamente atribuídas à RAM. Além disso, projeções internacionais indicam que, até 2050, a RAM poderá causar cerca de 10 milhões de mortes anuais caso medidas efetivas de controle não sejam implementadas. O problema impacta diretamente a segurança do paciente, aumentando o tempo de internação, os custos hospitalares, a ocorrência de infecções relacionadas à assistência à saúde (IRAS) e a mortalidade. Nesse contexto, estratégias como o uso racional de antimicrobianos, a prevenção de infecções, a higienização das mãos, a vigilância epidemiológica e a educação em saúde tornam-se fundamentais, destacando o papel estratégico da enfermagem no enfrentamento da RAM (OMS, 2023)."},
            {:figure, "figura_1.png", "Figura 1: Conceito de Resistência Antimicrobiana."},
            {:subtitle, "Leia a situação clínica abaixo:"},
            {:paragraph,
             "Paciente internado F.P.S. 58 anos, internado na Unidade de Terapia Intensiva (UTI) há 20 dias, evoluiu com pneumonia associada à ventilação mecânica. A cultura identifica bactéria multirresistente. O antibiótico inicialmente utilizado não apresenta resposta clínica."},
            {:list, "Antes de continuar, reflita individualmente:",
             [
               "Por que alguns antibióticos deixam de funcionar?",
               "Como o ambiente hospitalar pode favorecer resistência antimicrobiana?",
               "Como a resistência antimicrobiana impacta a segurança do paciente?",
               "Qual o papel da enfermagem nesse cenário?"
             ]}
          ]
        },
        %{
          slug: "conceito-de-ram",
          title: "Conceito de Resistência Antimicrobiana",
          heading: "Conceito de Resistência Antimicrobiana",
          blocks: [
            {:paragraph,
             "A RAM ocorre quando bactérias, vírus, fungos e parasitas desenvolvem mecanismos que lhes permitem sobreviver ou continuar se multiplicando mesmo após a exposição a medicamentos antimicrobianos anteriormente eficazes para seu controle ou eliminação. Esse fenômeno resulta da capacidade dos microrganismos de sofrer mutações genéticas ou adquirir genes de resistência, tornando os tratamentos menos eficazes e dificultando o controle das infecções."},
            {:paragraph,
             "Os antimicrobianos são medicamentos essenciais utilizados na prevenção e no tratamento de infecções causadas por diferentes microrganismos, atuando por meio da eliminação ou da inibição do crescimento desses agentes infecciosos. Segundo a Agência Nacional de Vigilância Sanitária (ANVISA), esse grupo terapêutico inclui diversas classes de medicamentos com ações específicas sobre determinados tipos de microrganismos."},
            {:paragraph,
             "O desenvolvimento da resistência está diretamente relacionado ao uso inadequado e excessivo dos antimicrobianos. Práticas como automedicação, interrupção precoce do tratamento, utilização de doses incorretas, prescrição desnecessária e uso indiscriminado desses medicamentos na saúde humana, animal e na produção agrícola favorecem a seleção de microrganismos resistentes. Nesse processo, os microrganismos sensíveis são eliminados, enquanto aqueles capazes de resistir ao medicamento sobrevivem, multiplicam-se e disseminam seus mecanismos de resistência."},
            {:figure, "figura_2.png",
             "Figura 2: Processo de seleção e disseminação da resistência antimicrobiana."},
            {:callout, "Conceito-chave",
             "A resistência antimicrobiana ocorre quando microrganismos desenvolvem capacidade de sobreviver à ação de medicamentos anteriormente eficazes."}
          ]
        },
        %{
          slug: "panorama-e-impactos",
          title: "Panorama Global e Nacional",
          heading: "Panorama Global e Nacional",
          blocks: [
            {:paragraph, "A OMS considera a RAM uma das principais ameaças globais à saúde."},
            {:subtitle, "Impactos globais"},
            {:list, nil,
             [
               "<strong>Aumento da mortalidade:</strong> infecções resistentes apresentam maior risco de morte.",
               "<strong>Crescimento de bactérias multirresistentes:</strong> hospitais registram aumento progressivo de microrganismos resistentes.",
               "<strong>Impacto em procedimentos complexos:</strong> a RAM compromete:<ul><li>Cirurgias;</li><li>Transplantes;</li><li>Terapias intensivas;</li><li>Tratamentos oncológicos.</li></ul>"
             ]},
            {:paragraph, "<strong>Sem antibióticos eficazes, procedimentos invasivos tornam-se mais perigosos.</strong>"},
            {:paragraph, "A ANVISA atua na vigilância e controle da resistência microbiana no Brasil."},
            {:list, "Principais ações da ANVISA",
             [
               "Monitoramento das Infecções Relacionadas à Assistência à Saúde (IRAS);",
               "Vigilância da resistência microbiana em serviços de saúde;",
               "Elaboração de protocolos de prevenção e controle de infecções;",
               "Promoção do uso racional de antimicrobianos;",
               "Fiscalização e regulamentação sanitária dos serviços de saúde;",
               "Capacitação e orientação de profissionais da saúde;",
               "Monitoramento laboratorial de microrganismos multirresistentes;",
               "Implementação de programas de stewardship antimicrobiano/PGA."
             ]},
            {:subtitle, "Impactos da RAM"},
            {:cards,
             [
               %{
                 title: "Impactos clínicos",
                 items: [
                   "Falha terapêutica;",
                   "Maior tempo de internação;",
                   "Aumento da mortalidade;",
                   "Limitação terapêutica."
                 ]
               },
               %{
                 title: "Impactos epidemiológicos",
                 items: [
                   "Surtos hospitalares;",
                   "Disseminação de bactérias resistentes;",
                   "Aumento das Infecções Relacionadas à Assistência à Saúde."
                 ]
               },
               %{
                 title: "Impactos econômicos",
                 items: [
                   "Aumento dos custos hospitalares;",
                   "Uso de medicamentos mais caros;",
                   "Necessidade de isolamento;",
                   "Sobrecarga do sistema de saúde."
                 ]
               }
             ]},
            {:figure, "figura_3.png",
             "Figura 3: Impactos da resistência antimicrobiana na assistência à saúde e na segurança do paciente."}
          ]
        },
        %{
          slug: "natural-x-adquirida",
          title: "Resistência Natural x Adquirida",
          heading: "Resistência natural x Resistência adquirida",
          blocks: [
            {:paragraph,
             "A diferenciação entre os tipos de resistência bacteriana é fundamental para a epidemiologia, dividindo-se principalmente em natural e adquirida. A resistência natural ocorre quando a bactéria já possui, de forma estrutural, mecanismos que impedem a ação de determinados medicamentos, como se observa na <em>Pseudomonas aeruginosa</em>, que apresenta resistência nativa a diversas classes de antimicrobianos. Por outro lado, a resistência adquirida desenvolve-se ao longo do tempo por meio de mutações genéticas ou pela troca de material genético entre diferentes microrganismos. Esse processo é fortemente impulsionado pela pressão seletiva causada pelo uso inadequado e abusivo de antimicrobianos, eliminando os microrganismos sensíveis e permitindo a sobrevivência das mutantes. É justamente a resistência adquirida que possui o maior impacto epidemiológico, por sua capacidade de se espalhar rapidamente e inviabilizar tratamentos de rotina."},
            {:figure, "figura_4.png", "Figura 4: Resistência natural e adquirida."}
          ]
        },
        %{
          slug: "pressao-seletiva",
          title: "Pressão Seletiva",
          heading: "Pressão seletiva",
          blocks: [
            {:paragraph,
             "O surgimento de populações bacterianas resistentes é impulsionado por um fenômeno biológico conhecido como pressão seletiva, frequentemente desencadeado pelo uso inadequado de antimicrobianos. Quando um medicamento é administrado de forma incorreta, ele elimina apenas os microrganismos que são sensíveis àquela substância. Os microrganismos que possuem alguma mutação protetora sobrevivem ao tratamento e, sem a competição do restante da colônia, encontram um cenário ideal para se multiplicarem livremente, transmitindo seus genes de resistência para as próximas gerações."},
            {:figure, "figura_5.png", "Figura 5: Pressão seletiva e resistência bacteriana."}
          ]
        },
        %{
          slug: "mecanismos-de-resistencia",
          title: "Mecanismos Básicos de Resistência",
          heading: "Mecanismos básicos de resistência",
          blocks: [
            {:list, nil,
             [
               "<strong>Produção de enzimas inativadoras:</strong> bactérias produzem enzimas capazes de destruir antibióticos. Exemplo: beta-lactamases.",
               "<strong>Alteração do sítio-alvo:</strong> a bactéria modifica a estrutura onde o antibiótico deveria agir. <strong>Resultado:</strong> o medicamento perde eficácia.",
               "<strong>Diminuição da permeabilidade:</strong> a bactéria reduz a entrada do antimicrobiano.",
               "<strong>Bombas de efluxo:</strong> o microrganismo expulsa o antibiótico para fora da célula.",
               "<strong>Formação de biofilme:</strong> biofilmes protegem bactérias contra:<ul><li>Ação antimicrobiana;</li><li>Resposta imunológica.</li></ul>São comuns em:<ul><li>Cateteres;</li><li>Próteses;</li><li>Ventilação mecânica;</li><li>Feridas.</li></ul>"
             ]},
            {:figure, "figura_6.png", "Figura 6: Mecanismos Básicos da Resistência."},
            {:reflection, "mecanismo-uti",
             "Qual mecanismo de resistência pode dificultar mais o tratamento de pacientes críticos internados em UTI? Descreva 1 delas abaixo:"}
          ]
        },
        %{
          slug: "superbacterias",
          title: "Superbactérias",
          heading: "Superbactérias",
          blocks: [
            {:paragraph,
             "As superbactérias são microrganismos que desenvolveram resistência a múltiplos antibióticos, tornando menos eficazes os tratamentos convencionais utilizados no controle das infecções. Entre os principais exemplos encontrados nos serviços de saúde destacam-se o <em>Staphylococcus aureus</em> resistente à meticilina (MRSA), a <em>Klebsiella pneumoniae</em> produtora de carbapenemase (KPC) e o <em>Acinetobacter</em> multirresistente. A presença desses patógenos reduz significativamente as opções terapêuticas disponíveis, dificultando o tratamento das infecções e aumentando o risco de complicações, tempo de internação, custos assistenciais e mortalidade hospitalar."},
            {:list, "Consequências:",
             [
               "Falha terapêutica;",
               "Internação prolongada;",
               "Maior mortalidade;",
               "Limitação terapêutica."
             ]}
          ]
        },
        %{
          slug: "ram-iras-seguranca",
          title: "RAM, IRAS e Segurança do Paciente",
          heading: "RAM, infecções relacionadas à assistência à saúde (IRAS) e segurança do paciente",
          blocks: [
            {:paragraph,
             "A RAM está diretamente relacionada às IRAS e representa um importante desafio para a segurança do paciente nos serviços de saúde. Ambientes hospitalares caracterizados pelo uso frequente de antimicrobianos, alta circulação de microrganismos e realização contínua de procedimentos invasivos favorecem o surgimento e a disseminação de microrganismos resistentes. Nesse contexto, as IRAS tornam-se um dos principais cenários de desenvolvimento da RAM, especialmente quando associadas à utilização prolongada de dispositivos invasivos e à baixa adesão às medidas de prevenção e controle de infecções."},
            {:paragraph,
             "Entre as principais IRAS associadas à RAM destacam-se a pneumonia associada à ventilação mecânica (PAV), a infecção urinária relacionada ao uso de cateter vesical de demora (ITU-CVD), a infecção primária da corrente sanguínea (IPCS) e a infecção de sítio cirúrgico (ISC). Essas infecções estão frequentemente relacionadas ao aumento da falha terapêutica, necessidade de utilização de antimicrobianos de amplo espectro ou de segunda linha, maior toxicidade medicamentosa, prolongamento da internação e aumento da mortalidade hospitalar."},
            {:paragraph,
             "Além disso, a RAM compromete diretamente a segurança do paciente ao elevar o risco de complicações clínicas, disseminação de microrganismos multirresistentes e ocorrência de surtos hospitalares. Fatores como uso inadequado de antibióticos, falhas na higienização das mãos, erros na administração de medicamentos, utilização prolongada de dispositivos invasivos e baixa adesão aos protocolos assistenciais intensificam a pressão seletiva bacteriana e favorecem a propagação da resistência microbiana nos serviços de saúde."},
            {:figure, "figura_7.png", "Figura 7: Mapa Interativo."}
          ]
        },
        %{
          slug: "papel-da-enfermagem",
          title: "Papel da Enfermagem",
          heading: "Papel da enfermagem no enfrentamento da RAM",
          blocks: [
            {:paragraph,
             "Diante desse cenário, estratégias como o uso racional de antimicrobianos, a prevenção das IRAS, a vigilância epidemiológica e o fortalecimento dos Programas de Gerenciamento de Antimicrobianos (PGA) tornam-se fundamentais para conter a disseminação da resistência."},
            {:list,
             "A enfermagem desempenha papel estratégico nesse processo por atuar diretamente na assistência ao paciente, na prevenção de infecções e na promoção da segurança assistencial. Entre suas principais atribuições destacam-se:",
             [
               "Prevenção e controle de infecções;",
               "Administração segura de antimicrobianos;",
               "Vigilância clínica dos pacientes;",
               "Educação em saúde para pacientes e familiares;",
               "Promoção da segurança do paciente;",
               "Participação em programas de uso racional de antimicrobianos."
             ]},
            {:paragraph,
             "Por estar presente continuamente nos diferentes níveis de atenção à saúde, a enfermagem ocupa posição fundamental na identificação precoce de riscos, na adesão às medidas de prevenção e no fortalecimento das estratégias de enfrentamento da RAM."},
            {:figure, "figura_8.png",
             "Figura 8: Principais atribuições da enfermagem no enfrentamento da resistência antimicrobiana."}
          ]
        },
        %{
          slug: "atividade-interativa",
          title: "Atividade Interativa com Chatbot",
          heading: "Atividade Interativa com Chatbot",
          blocks: [
            {:subtitle, "Objetivo"},
            {:paragraph, "Aplicar os conhecimentos adquiridos em uma situação clínica simulada."},
            {:subtitle, "Caso clínico"},
            {:paragraph,
             "Paciente masculino, 74 anos, diabético, internado há 21 dias em UTI após cirurgia abdominal. Evolui com febre persistente, secreção pulmonar purulenta e piora respiratória. Está em ventilação mecânica, possui cateter venoso central e sonda vesical de demora. Cultura identifica <em>Klebsiella pneumoniae</em> multirresistente."},
            {:list,
             "Orientações: utilize o chatbot educacional para responder, a partir do caso clínico apresentado:",
             [
               "Quais fatores contribuíram para o desenvolvimento da resistência antimicrobiana?",
               "Quais Infecções Relacionadas à Assistência à Saúde podem estar associadas?",
               "Quais mecanismos de resistência podem estar envolvidos?",
               "Como a segurança do paciente está comprometida?",
               "Quais cuidados de enfermagem devem ser priorizados?",
               "Quais medidas preventivas poderiam evitar esse quadro?"
             ]},
            {:callout, "Importante",
             "O chatbot deve ser utilizado como ferramenta de apoio ao raciocínio crítico. Analise as respostas recebidas e compare com os conteúdos estudados ao longo do módulo."}
          ]
        },
        %{
          slug: "referencias",
          title: "Referências",
          heading: "Referências",
          blocks: [
            {:references,
             [
               "AGÊNCIA NACIONAL DE VIGILÂNCIA SANITÁRIA (ANVISA). <strong>Diretriz nacional para elaboração de programa de gerenciamento do uso de antimicrobianos em serviços de saúde.</strong> Brasília: ANVISA, 2023. Disponível em: https://www.gov.br/anvisa/pt-br/centraisdeconteudo/publicacoes/servicosdesaude/publicacoes/diretriz-nacional-para-elaboracao-de-programa-de-gerenciamento-do-uso-de-antimicrobianos-em-servicos-de-saude.pdf/.",
               "AMERICAN NURSE. <strong>Quality improvement initiative to enhance nurse engagement in antibiotic stewardship.</strong> [S. l.]: American Nurse Journal, 2024. Disponível em: https://www.myamericannurse.com/quality-improvement-initiative-to-enhance-nurse-engagement-in-antibiotic-stewardship/.",
               "BRASIL. Ministério da Saúde. <strong>Plano de ação nacional de prevenção e controle da resistência aos antimicrobianos no âmbito de uma só saúde 2026-2030.</strong> Brasília: Ministério da Saúde, 2026. Disponível em: https://www.gov.br/saude/pt-br/centrais-de-conteudo/publicacoes/guias-e-manuais/2026/plano-de-acao-nacional-de-prevencao-e-controle-da-resistencia-aos-antimicrobianos-no-ambito-de-uma-so-saude-2026-2030.pdf.",
               "BRASIL. Ministério da Saúde. <strong>RAM no Brasil: Saúde de A a Z.</strong> Brasília, DF: Ministério da Saúde, [s.d.]. Disponível em: https://www.gov.br/saude/pt-br/assuntos/saude-de-a-a-z/r/ram/ram-no-brasil.",
               "CAMERINI, Flavia Giron et al. Nursing strategies in antimicrobial stewardship in the hospital environment: a qualitative systematic review. <strong>BMC Nursing</strong>, Londres, v. 23, art. 147, p. 1-12, 2024. DOI: https://doi.org/10.1186/s12912-024-01753-y. Disponível em: https://doi.org/10.1186/s12912-024-01753-y.",
               "CARNEIRO, M.; PILLONETTO, M. Fighting antimicrobial resistance in Brazil: strengthening diagnostic stewardship, antimicrobial stewardship, and policies for a healthier future. <strong>Frontiers in Public Health</strong>, v. 13, p. 1-10, 2025. DOI: 10.3389/fpubh.2025.1726000. Disponível em: https://doi.org/10.3389/fpubh.2025.1726000.",
               "CENTERS FOR DISEASE CONTROL AND PREVENTION (CDC). <strong>About antimicrobial resistance.</strong> Atlanta: CDC, 2025. Disponível em: https://www.cdc.gov/antimicrobial-resistance/about/index.html.",
               "ELMI, A. H. Nurses' roles in prevention and control of antimicrobial resistance: A narrative review. <strong>Journal of Nursing Reports in Clinical Practice</strong>, v. 3, n. 1, p. 1-12, 2025. DOI: 10.32598/JNRCP.2506.1288.",
               "MOMIN, S. et al. Development of antimicrobial stewardship competencies: A pan-Canadian framework for nurses. <strong>Canadian Journal of Infection Control</strong>, v. 40, n. 2, p. 30-38, 2025. Disponível em: https://www.cjic.ca/contents/current-issue/430-development-of-antimicrobial-stewardship-competencies-a-pan-canadian-framework-for-nurses.",
               "MURRAY, P.E.; COFFMAN, J.A.; GARCIÁ-GODOY, F. Antimicrobial Resistance: A Bibliometric Review of Patient Health, Mechanisms, and Therapeutic Strategies. <strong>Pathogens</strong>, v. 15, p. 288, 2026. Disponível em: https://doi.org/10.3390/pathogens15030288.",
               "NATIONAL COMMISSION ON CORRECTIONAL HEALTH CARE (NCCHC). <strong>Antimicrobial Stewardship (2026): position statements.</strong> Chicago: NCCHC, 2026. Disponível em: https://ncchc.org/position-statements/antimicrobial-stewardship-2026/.",
               "ORGANIZAÇÃO MUNDIAL DA SAÚDE (OMS). <strong>Antimicrobial resistance.</strong> Genebra: World Health Organization, 2023. Disponível em: https://www.who.int/news-room/fact-sheets/detail/antimicrobial-resistance."
             ]}
          ]
        },
        %{
          slug: "avaliacao",
          title: "Avaliação",
          heading: "Avaliação",
          blocks: [
            {:quiz, "avaliacao",
             [
               %{
                 prompt: "A resistência antimicrobiana ocorre principalmente devido:",
                 options: [
                   {"a", "Uso racional de antibióticos"},
                   {"b", "Higienização correta das mãos"},
                   {"c", "Uso inadequado e excessivo de antimicrobianos"},
                   {"d", "Redução das Infecções Relacionadas à Assistência à Saúde"}
                 ],
                 answer: "c"
               },
               %{
                 prompt: "Qual alternativa representa mecanismo bacteriano de resistência?",
                 options: [
                   {"a", "Hipotermia"},
                   {"b", "Produção de beta-lactamases"},
                   {"c", "Hiperglicemia"},
                   {"d", "Sedação contínua"}
                 ],
                 answer: "b"
               },
               %{
                 prompt:
                   "As Infecções Relacionadas à Assistência à Saúde contribuem para resistência antimicrobiana porque:",
                 options: [
                   {"a", "Reduzem internações"},
                   {"b", "Eliminam transmissão bacteriana"},
                   {"c", "Favorecem disseminação de microrganismos resistentes"},
                   {"d", "Impedem uso de antibióticos"}
                 ],
                 answer: "c"
               },
               %{
                 prompt: "O uso racional de antimicrobianos inclui:",
                 options: [
                   {"a", "Administração correta, dose adequada e tempo correto de tratamento"},
                   {"b", "Utilização de antibióticos sem prescrição"},
                   {"c", "Interrupção do tratamento ao melhorar os sintomas"},
                   {"d", "Compartilhamento de antibióticos entre pacientes"}
                 ],
                 answer: "a"
               },
               %{
                 prompt:
                   "Qual das alternativas representa uma medida importante da enfermagem na prevenção da resistência antimicrobiana?",
                 options: [
                   {"a", "Higiene das mãos uma vez ao turno"},
                   {"b", "Uso indiscriminado de antibióticos"},
                   {"c", "Suspensão de protocolos de isolamento"},
                   {"d", "Administração segura de antimicrobianos e precauções de contato"}
                 ],
                 answer: "d"
               }
             ],
             [
               "O enfrentamento da resistência antimicrobiana depende de práticas seguras, vigilância contínua e atuação crítica da equipe multiprofissional.",
               "No próximo módulo, serão abordados os antimicrobianos na prática clínica, incluindo administração segura, uso racional e monitoramento realizado pela enfermagem."
             ]}
          ]
        }
      ]
    }
  end

  defp course_2 do
    %{
      number: 2,
      title: "Curso 2",
      subtitle: "Antibióticos na prática clínica",
      sections: [
        %{
          slug: "introducao",
          title: "Introdução e Problematização",
          heading: "Introdução e Problematização",
          blocks: [
            {:paragraph,
             "Após compreender como a resistência antimicrobiana (RAM) se desenvolve e ameaça a segurança do paciente, surge uma questão fundamental: como garantir que os antibióticos sejam administrados de forma segura e eficaz na prática clínica?"},
            {:paragraph,
             "Os antibióticos são essenciais para o tratamento das infecções bacterianas. Entretanto, sua eficácia depende da indicação adequada e da administração correta. Dose, horário, intervalo, diluição, compatibilidade, tempo de infusão e monitoramento clínico podem interferir nos resultados do tratamento. Atrasos repetidos, doses omitidas, infusões inadequadas e falhas na identificação de reações adversas aumentam os riscos ao paciente."},
            {:paragraph,
             "A Enfermagem participa diretamente do preparo, da administração, do monitoramento e do registro da antibioticoterapia. Também contribui para a coleta adequada de culturas, a identificação de alergias, o reconhecimento de eventos adversos e a comunicação de alterações clínicas."},
            {:paragraph,
             "Neste módulo, você participará de um plantão simulado. Cada decisão será analisada quanto à segurança do paciente e ao uso racional dos antibióticos."},
            {:intro_list,
             "<strong>Caso disparador:</strong> Você inicia o plantão em uma unidade de internação e recebe três pacientes em antibioticoterapia:",
             [
               "um paciente com pneumonia e prescrição de meropenem;",
               "uma paciente com suspeita de infecção por bactéria gram-positiva resistente e prescrição de vancomicina;",
               "um paciente com infecção urinária, redução da função renal e prescrição de amicacina."
             ]},
            {:paragraph,
             "Durante o plantão, surgem diferentes problemas: uma primeira dose ainda não foi administrada, dois medicamentos precisam utilizar o mesmo acesso venoso, um paciente relata alergia à penicilina e outro apresenta prurido e rubor durante a infusão."},
            {:callout, "Pergunta inicial",
             "quais informações devem ser verificadas antes de administrar os antibióticos e quais alterações exigem intervenção imediata da Enfermagem?"}
          ]
        },
        %{
          slug: "conceito",
          title: "Conceito de Antimicrobianos",
          heading: "Conceito",
          blocks: [
            {:intro_list,
             "Antimicrobianos são medicamentos utilizados no tratamento de infecções causadas por microrganismos. Incluem:",
             [
               "antibacterianos ou antibióticos;",
               "antivirais;",
               "antifúngicos;",
               "antiparasitários;",
               "antimicobacterianos."
             ]},
            {:paragraph,
             "Neste módulo, o termo antibiótico será utilizado para designar os medicamentos destinados ao tratamento de infecções bacterianas."},
            {:paragraph,
             "A observação da atividade antibacteriana da penicilina por Alexander Fleming, em 1928, e seu posterior desenvolvimento para uso clínico contribuíram para uma importante redução da morbimortalidade por infecções bacterianas. Entretanto, o crescimento do consumo e o uso inadequado desses medicamentos têm favorecido a seleção de microrganismos resistentes."},
            {:paragraph,
             "O antibiótico não atua contra vírus. Portanto, sua utilização em infecções virais sem evidência ou suspeita de infecção bacteriana não oferece benefício e pode causar eventos adversos, alterar a microbiota e aumentar a pressão seletiva sobre as bactérias (Klein et al. 2024)."},
            {:figure, "figura_1.png", "Figura 1: Conceito de Antimicrobianos."}
          ]
        },
        %{
          slug: "mecanismos-de-acao",
          title: "Principais Mecanismos de Ação",
          heading: "Principais mecanismos de ação",
          blocks: [
            {:paragraph,
             "Os antibióticos atuam sobre estruturas ou processos essenciais à sobrevivência e à multiplicação bacteriana."},
            {:table, ["Alvo bacteriano", "Mecanismo", "Classes exemplificativas"],
             [
               ["Parede celular", "Interferência na formação do peptidoglicano",
                "Penicilinas, cefalosporinas, carbapenêmicos e glicopeptídeos"],
               ["Ribossomos", "Inibição da síntese proteica",
                "Aminoglicosídeos, macrolídeos, tetraciclinas, lincosamidas e oxazolidinonas"],
               ["DNA ou RNA", "Interferência na replicação ou transcrição",
                "Fluoroquinolonas e rifamicinas"],
               ["Vias metabólicas", "Inibição da síntese do ácido fólico",
                "Sulfonamidas e trimetoprima"],
               ["Membrana celular", "Alteração da integridade da membrana",
                "Polimixinas e daptomicina"]
             ]},
            {:intro_list, "Os antibióticos também podem ser classificados, de maneira geral, como:",
             [
               "<strong>bactericidas:</strong> provocam a morte bacteriana;",
               "<strong>bacteriostáticos:</strong> inibem o crescimento e a multiplicação bacteriana."
             ]},
            {:paragraph,
             "Essa classificação não deve ser interpretada de forma absoluta. O efeito pode variar conforme o antibiótico, a concentração alcançada, o microrganismo, o sítio da infecção e as condições imunológicas do paciente."},
            {:figure, "figura_2.png", "Figura 2: Estrutura bacteriana e alvos dos antibióticos.",
             "Fonte: uso da ferramenta chat GPT para criação da imagem com revisão dos autores."}
          ]
        },
        %{
          slug: "classes-de-antibioticos",
          title: "Principais Classes de Antibióticos",
          heading: "Principais classes de antibióticos",
          blocks: [
            {:subtitle, "Beta-lactâmicos (penicilinas, cefalosporinas e carbapenêmicos)"},
            {:paragraph,
             "<strong><em>Mecanismo/Alvo:</em></strong> inibem a síntese da <strong>parede celular</strong> bacteriana, fragilizando a estrutura da bactéria até que ela sofra lise (rompimento) pelo efeito osmótico."},
            {:paragraph,
             "<strong><em>Exemplos hospitalares:</em></strong> piperacilina + tazobactam, ceftriaxone, cefalotina, cefepime, meropenem."},
            {:intro_list, "<strong>Principais cuidados:</strong>",
             [
               "verificar história de alergias;",
               "observar manifestações cutâneas, respiratórias ou hemodinâmicas;",
               "conferir diluente, estabilidade e tempo de infusão;",
               "monitorar função renal quando indicado."
             ]},
            {:subtitle, "Glicopeptídeos"},
            {:paragraph,
             "<strong><em>Mecanismo/Alvo:</em></strong> também agem na <strong>parede celular</strong>, mas ligam-se a precursores específicos (D-ala-D-ala), impedindo o entrelaçamento da parede. São direcionados a bactérias Gram-positivas complexas."},
            {:paragraph,
             "<strong><em>Exemplos hospitalares:</em></strong> vancomicina e teicoplanina."},
            {:intro_list, "<strong>Principais cuidados:</strong>",
             [
               "respeitar o tempo de infusão;",
               "avaliar o acesso venoso;",
               "monitorar a função renal;",
               "observar sinais de reação à infusão."
             ]},
            {:subtitle, "Aminoglicosídeos"},
            {:paragraph,
             "<strong><em>Mecanismo/Alvo:</em></strong> interferem na síntese de proteínas bacterianas, <strong>bloqueando a síntese de proteínas</strong> essenciais."},
            {:paragraph,
             "<strong><em>Exemplos hospitalares:</em></strong> gentamicina e amicacina."},
            {:intro_list, "<strong>Principais cuidados:</strong>",
             [
               "monitorar função renal e débito urinário;",
               "observar zumbido, redução da audição, tontura ou desequilíbrio;",
               "verificar uso concomitante de outros medicamentos nefrotóxicos;",
               "acompanhar níveis séricos quando indicados."
             ]},
            {:subtitle, "Quinolonas / Fluoroquinolonas"},
            {:paragraph,
             "<strong><em>Mecanismo/Alvo:</em></strong> interferem na replicação do DNA bacteriano."},
            {:paragraph,
             "<strong><em>Exemplos hospitalares:</em></strong> ciprofloxacino e levofloxacino."},
            {:intro_list, "<strong>Principais cuidados:</strong>",
             [
               "observar sintomas neurológicos e alterações tendíneas;",
               "verificar interações medicamentosas;",
               "avaliar fatores de risco para prolongamento do intervalo QT;",
               "na administração oral, verificar interações com antiácidos, ferro e cálcio."
             ]},
            {:figure, "figura_3.png", "Figura 3: Principais classes de antibióticos."}
          ]
        },
        %{
          slug: "cim-na-pratica",
          title: "Concentração Inibitória Mínima (CIM)",
          heading: "Concentração Inibitória Mínima (CIM) na prática",
          blocks: [
            {:paragraph,
             "A Concentração Inibitória Mínima, ou CIM, é a menor concentração de um antibiótico capaz de inibir o crescimento visível de uma bactéria em laboratório."},
            {:intro_list, "A eficácia dos antibióticos pode estar relacionada a diferentes parâmetros:",
             [
               "<strong>tempo acima da CIM:</strong> especialmente importante para os beta-lactâmicos;",
               "<strong>pico de concentração:</strong> importante para os aminoglicosídeos;",
               "<strong>exposição total ao medicamento:</strong> importante para medicamentos como vancomicina e fluoroquinolonas."
             ]},
            {:paragraph,
             "Por isso, os horários, os intervalos e os tempos de infusão devem ser respeitados. O impacto de um atraso depende do medicamento, da duração do atraso, da função renal, do intervalo prescrito e das condições clínicas do paciente."},
            {:paragraph,
             "Atrasos repetidos ou prolongados podem reduzir a exposição ao antibiótico e comprometer a resposta terapêutica. Entretanto, não se deve afirmar que todo atraso provoca resistência imediatamente."},
            {:intro_list, "Diante de uma dose atrasada, a Enfermagem deve:",
             [
               "verificar o horário da dose anterior;",
               "avaliar quanto tempo decorreu;",
               "consultar o protocolo institucional;",
               "comunicar a equipe quando necessário;",
               "registrar o horário real e o motivo do atraso;",
               "reorganizar os próximos horários de maneira segura."
             ]},
            {:paragraph,
             "Não se deve duplicar a dose, acelerar a infusão ou aproximar os horários sem orientação."},
            {:subtitle, "Exemplo prático"},
            {:intro_list, "Paciente com pneumonia recebendo meropenem de 8 em 8 horas:",
             ["08h → dose administrada;", "16h → nova dose programada."]},
            {:intro_list, "Se a dose das 16h for administrada às 18h:",
             [
               "o medicamento pode ficar abaixo da CIM por algumas horas;",
               "as bactérias voltam a crescer;",
               "o risco de falha terapêutica aumenta."
             ]},
            {:paragraph,
             "<strong>O que a enfermagem precisa lembrar?</strong> Administrar o antibiótico no horário correto não é apenas cumprir uma prescrição. É uma ação fundamental para manter o medicamento eficaz, evitar falhas no tratamento e ajudar a combater a RAM."},
            {:callout, "Regra de Ouro",
             "antibiótico atrasado pode significar bactéria fortalecida. Por isso, o horário da administração é uma das responsabilidades mais importantes da enfermagem na terapia antimicrobiana."},
            {:figure, "figura_4.png",
             "Figura 4: Relação entre exposição ao antibiótico, CIM e horários de administração.",
             "Fonte: uso da ferramenta chat GPT para criação da imagem com revisão dos autores."}
          ]
        },
        %{
          slug: "aprazamento-interacoes",
          title: "Aprazamento, Interações e Incompatibilidades",
          heading: "Aprazamento seguro, interações e incompatibilidades",
          blocks: [
            {:subtitle, "Aprazamento"},
            {:intro_list,
             "<strong>Aprazamento</strong> é a organização dos horários de administração dos medicamentos prescritos. Deve considerar:",
             [
               "horário da primeira dose;",
               "intervalo prescrito;",
               "tempo de infusão;",
               "medicamentos administrados anteriormente;",
               "coleta de culturas ou níveis séricos;",
               "número e condições dos acessos venosos;",
               "compatibilidade;",
               "função renal;",
               "continuidade entre os turnos."
             ]},
            {:paragraph,
             "A primeira dose deve ser priorizada, principalmente em pacientes graves. Quando culturas forem prescritas, elas devem ser coletadas antes do antibiótico sempre que possível, sem provocar atraso inadequado no tratamento."},
            {:subtitle, "Interação medicamentosa"},
            {:intro_list,
             "<strong>Interação medicamentosa</strong> ocorre quando um medicamento altera o efeito, a concentração ou a toxicidade de outro medicamento ou substância no organismo. Exemplos:",
             [
               "aumento do risco de nefrotoxicidade pelo uso concomitante de medicamentos nefrotóxicos;",
               "aumento do risco de alterações do ritmo cardíaco pela associação de medicamentos que prolongam o intervalo QT;",
               "redução da absorção oral de fluoroquinolonas pela administração simultânea com determinados cátions."
             ]},
            {:subtitle, "Incompatibilidade físico-química"},
            {:intro_list,
             "<strong>Incompatibilidade físico-química</strong> ocorre quando medicamentos ou soluções entram em contato na seringa, equipo, conector ou cateter e sofrem alterações físicas ou químicas. A incompatibilidade pode provocar:",
             [
               "precipitação;",
               "turvação;",
               "mudança de cor;",
               "formação de partículas;",
               "redução da estabilidade ou da eficácia."
             ]},
            {:paragraph, "A ausência de alteração visível não garante compatibilidade."},
            {:intro_list, "<strong>Conduta segura antes de administrar medicamentos pela mesma via:</strong>",
             [
               "verificar a compatibilidade em fonte institucional atualizada;",
               "conferir concentração, diluente e forma de administração;",
               "utilizar lúmens separados quando disponíveis;",
               "administrar separadamente quando a compatibilidade não estiver confirmada;",
               "realizar lavagem da via com solução compatível, conforme protocolo;",
               "consultar o farmacêutico diante de dúvida."
             ]},
            {:callout, "Atenção",
             "a compatibilidade entre vancomicina e piperacilina/tazobactam, por exemplo, pode variar conforme concentração, diluente e apresentação. Portanto, não deve ser presumida."}
          ]
        },
        %{
          slug: "nove-certos",
          title: "Os 9 Certos da Administração",
          heading: "Os 9 Certos da Administração de Medicamentos Aplicados aos Antimicrobianos",
          blocks: [
            {:paragraph,
             "Os nove certos funcionam como barreiras de segurança, mas não substituem o raciocínio clínico, os protocolos, a comunicação e a participação ativa do paciente."},
            {:cards,
             [
               %{
                 title: "1. Paciente certo",
                 items: [
                   "utilizar pelo menos dois identificadores;",
                   "não utilizar leito ou quarto como identificador;",
                   "comparar pulseira, prontuário e prescrição;",
                   "perguntar o nome ao paciente quando possível."
                 ]
               },
               %{
                 title: "2. Medicamento certo",
                 items: [
                   "conferir o nome do medicamento;",
                   "observar medicamentos com nomes ou embalagens semelhantes;",
                   "verificar alergias;",
                   "avaliar a indicação registrada;",
                   "conferir integridade, validade e condições do produto."
                 ]
               },
               %{
                 title: "3. Dose certa",
                 items: [
                   "comparar dose prescrita e apresentação disponível;",
                   "conferir cálculos;",
                   "considerar peso, idade e função renal quando aplicável;",
                   "realizar dupla checagem quando indicada;",
                   "esclarecer qualquer discrepância antes da administração."
                 ]
               },
               %{
                 title: "4. Via certa",
                 items: [
                   "confirmar a via prescrita;",
                   "avaliar a condição do acesso;",
                   "verificar se a via é apropriada para concentração, osmolaridade e duração da terapia;",
                   "observar sinais de infiltração, extravasamento, flebite ou infecção."
                 ]
               },
               %{
                 title: "5. Horário certo",
                 items: [
                   "considerar intervalo, tempo de infusão e horários anteriores;",
                   "priorizar a primeira dose quando indicada;",
                   "registrar e comunicar atrasos;",
                   "não modificar o esquema por conta própria."
                 ]
               },
               %{
                 title: "6. Forma farmacêutica certa",
                 items: [
                   "conferir apresentação;",
                   "utilizar o diluente correto;",
                   "observar necessidade de reconstituição;",
                   "não triturar, abrir ou modificar formas farmacêuticas sem verificar a segurança."
                 ]
               },
               %{
                 title: "7. Orientação certa",
                 intro: "Explicar ao paciente e à família:",
                 items: [
                   "finalidade do medicamento;",
                   "forma de administração;",
                   "importância de comunicar alergias;",
                   "sinais e sintomas que devem ser relatados;",
                   "importância da adesão ao tratamento."
                 ]
               },
               %{
                 title: "8. Registro certo",
                 intro: "Registrar:",
                 items: [
                   "medicamento;",
                   "dose;",
                   "via;",
                   "horário real;",
                   "local ou acesso utilizado quando pertinente;",
                   "resposta do paciente;",
                   "intercorrências;",
                   "medidas adotadas;",
                   "profissionais comunicados."
                 ]
               },
               %{
                 title: "9. Resposta certa",
                 intro: "Monitorar:",
                 items: [
                   "temperatura;",
                   "sinais vitais;",
                   "estado geral;",
                   "sinais e sintomas da infecção;",
                   "função renal e hepática;",
                   "exames laboratoriais;",
                   "condições do acesso;",
                   "eventos adversos;",
                   "evolução do foco infeccioso."
                 ]
               }
             ]},
            {:paragraph,
             "<strong>Sobre o registro:</strong> ele deve ser realizado após a administração. Medicamento não administrado também deve ser registrado, com o respectivo motivo."},
            {:list, "Antes de administrar, pergunte:",
             [
               "É o paciente correto?",
               "Há alergias?",
               "O medicamento, a dose, a via e o horário estão corretos?",
               "A diluição e o tempo de infusão foram conferidos?",
               "A compatibilidade foi verificada?",
               "O acesso está adequado?",
               "Quais respostas e eventos adversos deverão ser monitorados?"
             ]},
            {:figure, "figura_5.png", "Figura 5: Nove certos da administração de antibióticos."}
          ]
        },
        %{
          slug: "vigilancia-beira-leito",
          title: "Vigilância à Beira do Leito",
          heading: "Vigilância à beira do leito",
          blocks: [
            {:paragraph,
             "A administração do antibiótico não encerra o cuidado de Enfermagem. O paciente deve ser monitorado durante e após a administração."},
            {:subtitle, "Flebite"},
            {:paragraph,
             "Flebite é a inflamação da veia, podendo estar relacionada ao cateter, ao tempo de permanência, à técnica ou às características da solução infundida."},
            {:intro_list, "<strong>Sinais:</strong>",
             [
               "dor;",
               "eritema;",
               "calor;",
               "edema;",
               "endurecimento;",
               "cordão venoso palpável."
             ]},
            {:intro_list, "<strong>Conduta:</strong>",
             [
               "interromper a infusão no acesso afetado;",
               "avaliar e classificar a flebite;",
               "remover o cateter quando indicado;",
               "adotar medidas locais conforme protocolo;",
               "obter novo acesso, se necessário;",
               "comunicar e registrar o evento."
             ]},
            {:subtitle, "Reações alérgicas e anafilaxia"},
            {:paragraph,
             "As reações podem variar de manifestações cutâneas leves até anafilaxia."},
            {:intro_list, "<strong>Sinais de alerta:</strong>",
             [
               "urticária;",
               "prurido;",
               "edema de lábios ou língua;",
               "dificuldade respiratória;",
               "broncoespasmo;",
               "estridor;",
               "hipotensão;",
               "alteração do nível de consciência."
             ]},
            {:paragraph,
             "A ausência de manifestações cutâneas não exclui anafilaxia."},
            {:intro_list, "<strong>Conduta inicial diante de suspeita de anafilaxia:</strong>",
             [
               "interromper imediatamente o medicamento;",
               "acionar o protocolo institucional de emergência;",
               "avaliar vias aéreas, respiração e circulação;",
               "monitorar sinais vitais e saturação;",
               "manter o acesso venoso com solução compatível por novo equipo;",
               "preparar adrenalina intramuscular conforme protocolo;",
               "disponibilizar oxigênio e materiais para atendimento;",
               "registrar as manifestações, as condutas e a resposta."
             ]},
            {:callout, "Importante",
             "a adrenalina intramuscular é o tratamento de primeira linha. Anti-histamínicos e corticoides não substituem nem devem atrasar sua administração."},
            {:subtitle, "Reação à infusão de vancomicina"},
            {:paragraph,
             "A reação à infusão de vancomicina, anteriormente denominada “Síndrome do Homem Vermelho”, está geralmente relacionada à velocidade de infusão."},
            {:intro_list, "<strong>Sinais:</strong>",
             [
               "rubor em face, pescoço e tronco;",
               "prurido;",
               "sensação de calor;",
               "hipotensão."
             ]},
            {:paragraph,
             "Em geral, não corresponde a uma alergia mediada por imunoglobulina E. Entretanto, o paciente deve ser avaliado para diferenciar a reação à infusão de anafilaxia."},
            {:intro_list, "<strong>Conduta:</strong>",
             [
               "interromper a infusão;",
               "avaliar vias aéreas, respiração e circulação;",
               "monitorar sinais vitais;",
               "comunicar a equipe;",
               "administrar medicamentos quando prescritos;",
               "reiniciar somente após avaliação e orientação;",
               "respeitar o tempo de infusão nas doses posteriores."
             ]}
          ]
        },
        %{
          slug: "toxicidade",
          title: "Toxicidade Relacionada aos Antibióticos",
          heading: "Toxicidade relacionada aos antibióticos",
          blocks: [
            {:subtitle, "Nefrotoxicidade"},
            {:paragraph,
             "Pode ocorrer principalmente com vancomicina, aminoglicosídeos e polimixinas."},
            {:intro_list, "<strong>Monitorar:</strong>",
             [
               "creatinina e sua evolução;",
               "débito urinário;",
               "balanço hídrico;",
               "uso concomitante de outros nefrotóxicos;",
               "níveis séricos, quando indicados."
             ]},
            {:paragraph, "A elevação da ureia isoladamente não confirma lesão renal."},
            {:subtitle, "Ototoxicidade"},
            {:paragraph, "Relaciona-se principalmente aos aminoglicosídeos."},
            {:intro_list, "<strong>Sinais:</strong>",
             [
               "zumbido;",
               "redução da audição;",
               "tontura;",
               "vertigem;",
               "alteração do equilíbrio."
             ]},
            {:subtitle, "Conduta da Enfermagem"},
            {:list, nil,
             [
               "monitorar sinais, sintomas e exames;",
               "identificar tendências de piora;",
               "comunicar alterações precocemente;",
               "registrar as intercorrências;",
               "acompanhar as condutas prescritas."
             ]}
          ]
        },
        %{
          slug: "resposta-clinica-inadequada",
          title: "Resposta Clínica Inadequada",
          heading: "Resposta clínica inadequada ou deterioração",
          blocks: [
            {:paragraph,
             "A ausência de melhora não significa necessariamente resistência bacteriana. O enfermeiro deve observar a tendência clínica e comunicar sinais de deterioração."},
            {:subtitle, "Sinais de alerta"},
            {:list, nil,
             [
               "persistência ou recorrência da febre;",
               "hipotermia;",
               "taquicardia;",
               "taquipneia;",
               "hipotensão;",
               "queda da saturação;",
               "redução do débito urinário;",
               "alteração do nível de consciência;",
               "piora da dor;",
               "progressão de sinais locais;",
               "elevação ou ausência de melhora dos marcadores inflamatórios;",
               "aumento de leucócitos ou leucopenia;",
               "necessidade crescente de oxigênio;",
               "piora da função renal;",
               "sinais de sepse ou choque."
             ]},
            {:subtitle, "Possíveis causas"},
            {:list, nil,
             [
               "tempo insuficiente para resposta;",
               "foco infeccioso não controlado;",
               "abscesso ou dispositivo infectado;",
               "microrganismo resistente;",
               "escolha inadequada do antibiótico;",
               "dose ou exposição inadequada;",
               "baixa penetração no sítio;",
               "falha na administração;",
               "diagnóstico não infeccioso;",
               "infecção viral, fúngica ou parasitária;",
               "imunossupressão;",
               "complicação clínica não relacionada ao antibiótico."
             ]},
            {:subtitle, "Conduta de Enfermagem"},
            {:list, nil,
             [
               "reavaliar o paciente;",
               "verificar sinais vitais;",
               "aplicar instrumentos institucionais de identificação de deterioração;",
               "avaliar acesso, horários e registros de administração;",
               "conferir resultados laboratoriais e microbiológicos disponíveis;",
               "comunicar a equipe multiprofissional;",
               "acionar protocolo de sepse quando indicado;",
               "registrar os achados e as medidas adotadas."
             ]},
            {:callout, "Importante",
             "PCR, procalcitonina e leucócitos devem ser interpretados em conjunto com a evolução clínica, nunca isoladamente."},
            {:figure, "figura_6.png",
             "Figura 6: Principais eventos adversos e sinais de resposta clínica inadequada."}
          ]
        },
        %{
          slug: "comunicacao-interprofissional",
          title: "Comunicação Interprofissional",
          heading: "Comunicação interprofissional",
          blocks: [
            {:paragraph, "Diante de intercorrências, pode ser utilizada a estratégia SBAR."},
            {:table, ["Elemento", "Conteúdo"],
             [
               ["S – Situação", "O que está acontecendo agora?"],
               ["B – Background/Contexto",
                "Qual é o diagnóstico, o antibiótico e o histórico relevante?"],
               ["A – Avaliação",
                "Quais sinais, sintomas, dados vitais e alterações foram identificados?"],
               ["R – Recomendação", "O que precisa ser avaliado ou realizado imediatamente?"]
             ]},
            {:subtitle, "Exemplo"},
            {:list, nil,
             [
               "<strong>Situação:</strong> paciente iniciou prurido, rubor cervical e hipotensão durante a infusão de vancomicina.",
               "<strong>Contexto:</strong> vancomicina iniciada há 15 minutos em acesso periférico. Não há alergia documentada.",
               "<strong>Avaliação:</strong> infusão interrompida. Pressão arterial 88/54 mmHg, frequência cardíaca 112 bpm e saturação 95%. Sem estridor até o momento.",
               "<strong>Recomendação:</strong> solicito avaliação imediata e definição da conduta conforme protocolo para reação à infusão ou anafilaxia."
             ]},
            {:figure, "figura_7.png", "Figura 7: Comunicação interprofissional - SBAR."}
          ]
        },
        %{
          slug: "atividade-gamificada",
          title: "Atividade Gamificada",
          heading: "Atividade Gamificada",
          blocks: [{:game, "atividade-gamificada"}]
        }
      ]
    }
  end
end
