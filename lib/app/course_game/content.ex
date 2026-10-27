defmodule App.CourseGame.Content do
  @moduledoc """
  Conteúdo da atividade gamificada do Módulo 2 (Antibióticos na prática clínica).

  Cada item possui `axis` (`:effectiveness` ou `:safety`), usado no placar final, e
  `topic`, usado na tela de feedback reflexivo. As palavras-chave da Fase 1 devem
  estar em minúsculas e sem acentos: uma resposta é aceita quando contém, para cada
  grupo, ao menos um dos termos (casados no início de uma palavra).
  """

  @doc "Questões do pré-teste (sem feedback e sem pontuação)."
  def pretest do
    [
      %{
        id: "pre-1",
        prompt: "Os antimicrobianos são classificados clinicamente como:",
        options: [
          {"a", "Substâncias restritas ao combate de vírus respiratórios."},
          {"b", "Agentes direcionados a infecções fúngicas."},
          {"c", "Fármacos que atuam contra diferentes classes de microrganismos."},
          {"d", "Insumos terapêuticos de uso exclusivo na atenção básica."}
        ],
        answer: "c"
      },
      %{
        id: "pre-2",
        prompt: "Biologicamente, a Resistência Antimicrobiana intensifica-se devido a:",
        options: [
          {"a", "Alterações climáticas sazonais nas UTIs."},
          {"b", "Mutação e seleção por uso incorreto de fármacos."},
          {"c", "Aumento imediato da imunidade do hospedeiro."},
          {"d", "Falhas sistêmicas na higienização."}
        ],
        answer: "b"
      },
      %{
        id: "pre-3",
        prompt: "Uma diretriz central do Programa de Gerenciamento de Antimicrobianos é:",
        options: [
          {"a", "Otimizar a seleção, dose e via para preservar a eficácia."},
          {"b", "Substituir a internação hospitalar por terapias caseiras."},
          {"c", "Manter o uso empírico de antimicrobianos indefinidamente."},
          {"d", "Priorizar apenas antimicrobianos de última linha clínica."}
        ],
        answer: "a"
      },
      %{
        id: "pre-4",
        prompt: "O momento ideal para a equipe de enfermagem coletar hemoculturas é:",
        options: [
          {"a", "48 horas após a primeira dose do antibiótico."},
          {"b", "Apenas se houver falha terapêutica evidente."},
          {"c", "Antes da administração inicial do fármaco."},
          {"d", "Durante o pico febril vespertino do paciente."}
        ],
        answer: "c"
      },
      %{
        id: "pre-5",
        prompt:
          "Erros na velocidade de infusão de antimicrobianos injetáveis comprometem o tratamento porque:",
        options: [
          {"a", "Anulam a necessidade de aprazamento."},
          {"b", "Provocam danos ao acesso venoso do paciente."},
          {"c", "Causam resistência cruzada a analgésicos."},
          {"d", "Alteram a Concentração Inibitória Mínima."}
        ],
        answer: "d"
      },
      %{
        id: "pre-6",
        prompt: "O princípio dos “13 certos” na administração de medicamentos visa prevenir:",
        options: [
          {"a", "A obsolescência de equipamentos hospitalares."},
          {"b", "Incidentes e eventos adversos na assistência."},
          {"c", "O atraso na compra de insumos farmacêuticos."},
          {"d", "Incompatibilidades entre escalas de plantão."}
        ],
        answer: "b"
      },
      %{
        id: "pre-7",
        prompt:
          "Uma falha de aprazamento de antimicrobiano que gera dano temporário ao paciente caracteriza-se como:",
        options: [
          {"a", "Um evento adverso relacionado à medicação."},
          {"b", "Um quase-erro institucional inofensivo."},
          {"c", "Uma complicação inevitável da patologia base."},
          {"d", "Um incidente sem potencial de dano."}
        ],
        answer: "a"
      },
      %{
        id: "pre-8",
        prompt:
          "Qual ação prática diária realizada pela equipe de enfermagem impacta diretamente na prevenção da resistência antimicrobiana?",
        options: [
          {"a", "Avaliar exames laboratoriais e emitir laudos de infecção de corrente sanguínea."},
          {"b", "Cumprir os horários de aprazamento prescritos."},
          {"c", "Substituir a via intravenosa pela via oral."},
          {"d", "Suspender a antibioticoterapia assim que o paciente apresentar melhora clínica."}
        ],
        answer: "b"
      },
      %{
        id: "pre-9",
        prompt:
          "A sobreutilização de antimicrobianos em ambientes hospitalares e comunitários gera um fenômeno evolutivo direto que impulsiona o aumento da Resistência Antimicrobiana, conhecido como:",
        options: [
          {"a", "Aumento da imunidade cruzada na comunidade."},
          {"b", "Redução na taxa de metabolização hepática do fármaco."},
          {"c", "Seleção natural induzida por pressão terapêutica."},
          {"d", "Inativação imediata da microbiota residente por anticorpos."}
        ],
        answer: "c"
      },
      %{
        id: "pre-10",
        prompt:
          "No escopo do uso racional de antimicrobianos, a interrupção precoce de um tratamento prescrito sem indicação clínica formal acarreta qual risco assistencial e microbiológico?",
        options: [
          {"a", "Sobrevivência de cepas menos sensíveis e estímulo à resistência."},
          {"b", "Queda nos custos de internação hospitalar."},
          {"c", "Erradicação de bactérias comensais benéficas."},
          {"d", "Neutralização das enzimas hepáticas do paciente."}
        ],
        answer: "a"
      }
    ]
  end

  @doc "Fase 1: cinco questões descritivas de aquecimento."
  def phase1 do
    [
      %{
        id: "f1-1",
        topic: "Coleta de culturas antes do antibiótico",
        axis: :effectiveness,
        prompt:
          "Um paciente internado com sepse tem prescrição de antimicrobiano de amplo espectro para iniciar imediatamente, mas o médico solicitou hemocultura prévia. Qual deve ser a conduta prioritária do enfermeiro?",
        expected:
          "Coletar as hemoculturas rigorosamente antes de administrar a primeira dose do antimicrobiano para evitar resultados falso-negativos.",
        hint:
          "Atenção: administrar o antibiótico antes da coleta da cultura esteriliza o sangue temporariamente, mascarando o agente causal e prejudicando o tratamento.",
        keywords: [
          ["cole", "colh", "obter"],
          ["antes", "previ", "primeiro", "anterior", "precede"]
        ]
      },
      %{
        id: "f1-2",
        topic: "Tempo de infusão e Concentração Inibitória Mínima",
        axis: :safety,
        prompt:
          "A prescrição indica um antimicrobiano injetável que exige tempo de infusão rigoroso de 60 minutos para atingir a Concentração Inibitória Mínima. A equipe de enfermagem corre o soro em 15 minutos para otimizar o tempo. O que acontece?",
        expected:
          "Ocorre uma falha grave na farmacocinética do fármaco, reduzindo a eficácia e favorecendo a seleção de resistência bacteriana.",
        hint:
          "Lembre-se: o tempo de infusão incorreto altera a estabilidade e a meia-vida do antimicrobiano, comprometendo a eficácia beira-leito.",
        keywords: [
          [
            "eficaci",
            "eficaz",
            "subdos",
            "sub dos",
            "subterap",
            "abaixo",
            "resist",
            "cim",
            "concentra",
            "falha",
            "nivel",
            "meia vida",
            "farmacocinet"
          ]
        ]
      },
      %{
        id: "f1-3",
        topic: "Horário certo e aprazamento",
        axis: :effectiveness,
        prompt:
          "Um erro no cálculo do intervalo de aprazamento de um antibiótico de horário fixo deixa o paciente por horas em níveis subterapêuticos. Qual princípio dos “13 certos” foi violado?",
        expected: "O horário certo e o intervalo de aprazamento prescrito.",
        hint:
          "O aprazamento inadequado gera subdosagens que estimulam diretamente a adaptação de superbactérias.",
        keywords: [["horario", "hora certa", "aprazamento", "intervalo"]]
      },
      %{
        id: "f1-4",
        topic: "Transição para a via oral (PGA)",
        axis: :effectiveness,
        prompt:
          "O paciente apresenta melhora clínica significativa e estabilização de sinais vitais, mas permanece com acesso venoso e antibiótico IV desnecessário. Qual o papel da enfermagem na transição?",
        expected:
          "Comunicar a equipe médica e apoiar a transição segura para a via oral conforme os protocolos do Programa de Gerenciamento de Antimicrobianos.",
        hint:
          "O enfermeiro atua como sentinela na beira do leito, identificando oportunidades para reduzir riscos de infecção de corrente sanguínea associada a cateter.",
        keywords: [
          [
            "comunic",
            "inform",
            "notific",
            "avis",
            "sinaliz",
            "discut",
            "propor",
            "solicit",
            "sugeri",
            "equipe",
            "medic"
          ],
          ["oral", "transi", "descalon", "desescal", "suspen", "reavali"]
        ]
      },
      %{
        id: "f1-5",
        topic: "Precauções de contato e higiene das mãos",
        axis: :safety,
        prompt:
          "Um paciente colonizado por bactéria multirresistente (MDR) é admitido na unidade. Qual barreira de segurança deve ser implementada pela enfermagem?",
        expected:
          "Instituir precauções de contato imediatas e higienização rigorosa das mãos para evitar a disseminação cruzada na unidade.",
        hint:
          "O controle rigoroso de infecções cruzadas é a principal linha de defesa não farmacológica da enfermagem contra a RAM.",
        keywords: [
          ["contato", "isolamento", "isolar", "precauc", "higien", "maos", "lavagem", "alcool"]
        ]
      }
    ]
  end

  @doc "Fase 2: três casos clínicos em sequência, com complexidade crescente."
  def phase2 do
    [
      %{
        id: "f2-1",
        topic: "Alergia medicamentosa documentada",
        axis: :safety,
        title: "Caso 1",
        patient: "Homem, 45 anos, internado com infecção de pele e partes moles (celulite).",
        challenge:
          "Ao checar a prescrição médica para administrar a primeira dose do antibiótico, o enfermeiro verifica que foi prescrita Penicilina Benzatina. No entanto, no prontuário e na pulseira de identificação do paciente consta um alerta crítico: “Alergia grave à Penicilina (Anafilaxia prévia)”.",
        prompt: "Qual das opções possui a conduta correta?",
        options: [
          {"a",
           "Administrar o medicamento imediatamente conforme a prescrição médica para não atrasar o horário do aprazamento."},
          {"b",
           "Suspender a administração da medicação, checar o histórico com o paciente e contatar a equipe médica para reavaliação."},
          {"c",
           "Diluir o antibiótico em um volume maior de soro fisiológico para “diluir” o potencial alérgico."}
        ],
        answer: "b",
        correct_feedback:
          "Excelente! O enfermeiro atua como sentinela de segurança na beira do leito, prevenindo eventos adversos graves como o choque anafilático.",
        wrong_feedback:
          "Atenção à segurança do paciente: administrar fármacos com histórico de alergia documentada viola os 13 certos e expõe o paciente a risco de morte por anafilaxia.",
        hint:
          "Um alerta de alergia grave documentada pesa mais que o horário do aprazamento: confira com o paciente e comunique a equipe antes de qualquer dose."
      },
      %{
        id: "f2-2",
        topic: "Diluição e tempo de infusão",
        axis: :safety,
        title: "Caso 2",
        patient:
          "Mulher, 62 anos, internada em leito de internação clínica com quadro de infecção pulmonar, em uso de um antimicrobiano intravenoso de amplo espectro.",
        challenge:
          "O antimicrobiano prescrito exige rigor técnico no preparo: precisa ser diluído em 100 ml de SF 0,9% e infundido lentamente em exatamente 60 minutos. O plantão está agitado e o enfermeiro está muito ocupado.",
        prompt: "Qual das opções possui a conduta correta?",
        options: [
          {"a", "Substituir a via intravenosa por via oral para evitar o controle do gotejamento."},
          {"b", "Correr o antibiótico em 15 minutos, otimizando o tempo da equipe no plantão."},
          {"c", "Ajustar a bomba de infusão para o tempo de 60 minutos estipulado na prescrição."}
        ],
        answer: "c",
        correct_feedback:
          "Perfeito! O controle rigoroso do tempo de infusão e diluição correta protege a eficácia do tratamento.",
        wrong_feedback:
          "Atenção: uma infusão muito rápida reduz a meia-vida do antimicrobiano, gerando subdosagens plasmáticas que afetam a Concentração Inibitória Mínima e favorecem a seleção de Resistência Antimicrobiana.",
        hint:
          "O tempo de infusão faz parte da prescrição e não pode ser alterado por conta própria; a bomba de infusão ajuda a cumpri-lo."
      },
      %{
        id: "f2-3",
        topic: "Reavaliação e descalonamento do antibiótico",
        axis: :effectiveness,
        title: "Caso 3",
        patient:
          "Homem, 70 anos, em pós-operatório prolongado na unidade de internação, apresentando sinais de sepse tardia.",
        challenge:
          "O paciente já está em uso de um antibiótico de amplo espectro há 8 dias consecutivos. O enfermeiro observa na evolução que as culturas de vigilância já foram negativadas ou o foco infeccioso inicial foi controlado, mas o antibiótico continua sendo repetido na prescrição diária sem reavaliação.",
        prompt: "Qual das opções possui a conduta correta?",
        options: [
          {"a",
           "Continuar checando o antibiótico indefinidamente até que o médico encerre o plantão daqui a algumas semanas."},
          {"b",
           "Comunicar a equipe médica para propor a reavaliação, descalonação ou suspensão do antibiótico prolongado."},
          {"c", "Solicitar a troca imediata por um antibiótico de reserva de última linha."}
        ],
        answer: "b",
        correct_feedback:
          "Excelente! A enfermagem no Programa de Gerenciamento de Antimicrobianos atua ativamente no stewardship, evitando terapias prolongadas desnecessárias que impulsionam a pressão seletiva para superbactérias.",
        wrong_feedback:
          "Atenção: manter antimicrobianos de largo espectro sem reavaliação clínica estimula fortemente o surgimento de patógenos multirresistentes e prolonga o tempo de internação.",
        hint:
          "No Programa de Gerenciamento de Antimicrobianos, a Enfermagem contribui levando à equipe a necessidade de reavaliar o tratamento."
      }
    ]
  end

  @doc "Fase 3: prescrição x checagem; o aluno aponta qual “certo” foi violado."
  def phase3 do
    [
      %{
        id: "f3-a",
        topic: "Horário certo",
        axis: :effectiveness,
        title: "Cenário A",
        prescription: [
          {"Medicamento", "Meropenem 1 g"},
          {"Via", "IV"},
          {"Frequência", "8 em 8 horas"},
          {"Horários prescritos", "06h - 14h - 22h"}
        ],
        check: [
          {"Medicamento", "Meropenem 1 g IV"},
          {"Administração registrada", "06h - 15h - 23h"}
        ],
        answer: "horario",
        correct_feedback:
          "Excelente! O aprazamento incorreto gera flutuações plasmáticas que reduzem a Concentração Inibitória Mínima, favorecendo a seleção de resistência.",
        wrong_feedback:
          "Atenção: alterar os horários prescritos sem critério compromete o intervalo plasmático adequado do antimicrobiano.",
        hint: "Compare, horário a horário, o que foi prescrito com o que foi registrado."
      },
      %{
        id: "f3-b",
        topic: "Administração certa (tempo de infusão)",
        axis: :safety,
        title: "Cenário B",
        prescription: [
          {"Medicamento", "Vancomicina 1 g"},
          {"Via", "IV"},
          {"Diluição", "250 ml de SF 0,9%"},
          {"Tempo de infusão", "60 minutos"}
        ],
        check: [
          {"Medicamento", "Vancomicina 1 g IV em 250 ml de SF 0,9%"},
          {"Administração registrada", "Infusão rápida concluída em 15 minutos"}
        ],
        answer: "administracao",
        correct_feedback:
          "Perfeito! Respeitar o tempo de infusão evita eventos adversos graves e garante a eficácia do fármaco.",
        wrong_feedback:
          "Atenção: infundir antimicrobianos fora do tempo recomendado altera a meia-vida do medicamento e corrompe a segurança beira-leito.",
        hint: "Observe o tempo de infusão prescrito e compare com o tempo registrado."
      },
      %{
        id: "f3-c",
        topic: "Via certa",
        axis: :effectiveness,
        title: "Cenário C",
        prescription: [
          {"Medicamento", "Polimixina B"},
          {"Via", "IV"}
        ],
        check: [
          {"Medicamento", "Polimixina B"},
          {"Administração registrada", "Administrado por via intramuscular"}
        ],
        answer: "via",
        correct_feedback:
          "Excelente! Erros de via em antimicrobianos de alto risco invalidam o tratamento e provocam sérios danos teciduais ao paciente.",
        wrong_feedback:
          "Atenção: a via de administração é um dos pilares invioláveis dos 13 certos da medicação.",
        hint: "Compare por onde o medicamento foi prescrito e por onde foi administrado."
      }
    ]
  end

  @doc "Os 13 certos da administração de medicamentos, alternativas da Fase 3."
  def certos do
    [
      {"paciente", "Paciente certo"},
      {"medicamento", "Medicamento certo"},
      {"dose", "Dose certa"},
      {"via", "Via certa"},
      {"horario", "Horário certo"},
      {"administracao", "Administração certa"},
      {"registro", "Registro certo"},
      {"forma", "Forma farmacêutica certa"},
      {"orientacao", "Orientação certa"},
      {"resposta", "Resposta certa"},
      {"indicacao", "Indicação certa"},
      {"validade", "Validade certa"},
      {"compatibilidade", "Compatibilidade certa"}
    ]
  end
end
