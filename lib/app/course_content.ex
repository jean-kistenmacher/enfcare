defmodule App.CourseContent do
  @moduledoc """
  Conteúdo (seções e blocos) das páginas de andamento dos cursos/módulos.

  Cada curso é identificado pelo número do módulo (posição na lista de módulos)
  e possui `sections`, exibidas no aside da página. Cada seção possui `blocks`,
  renderizados em ordem pela página:

    * `{:paragraph, html}` - parágrafo (HTML estático confiável)
    * `{:subtitle, text}` - subtítulo dentro da seção
    * `{:figure, file, caption}` - figura em `priv/static/images/cursos/curso_N/`
    * `{:list, title | nil, items}` - lista com marcadores
    * `{:callout, label, text}` - destaque (ex.: conceito-chave)
    * `{:cards, [%{title: t, items: [..]}]}` - quadros lado a lado
    * `{:reflection, key, prompt}` - campo de autorreflexão
    * `{:references, [html]}` - lista de referências bibliográficas
    * `{:quiz, key, questions, closing}` - questões de múltipla escolha, respondidas
      uma por vez; `closing` são os parágrafos exibidos ao final da avaliação
  """

  @source "Fonte: uso da ferramenta chat GPT para criação da imagem."

  @doc "Retorna o curso do módulo `number` ou `nil` se ainda não possui conteúdo."
  def get(1), do: course_1()
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
end
