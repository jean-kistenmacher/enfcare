let Hooks = {}

Hooks.ProtocolSession = {
  mounted() {
    const courseId = this.el.dataset.courseId;
    const storageKey = `protocol_completed_${courseId}`;
    
    // Verificar se o protocolo já foi completado
    const isCompleted = sessionStorage.getItem(storageKey);
    
    if (isCompleted === 'true') {
      // Notificar o servidor que o formulário já foi preenchido
      this.pushEvent("restore_session", { completed: true });
    }
    
    // Escutar evento de clique no botão do formulário
    this.handleEvent("mark_completed", () => {
      sessionStorage.setItem(storageKey, 'true');
    });
  }
}

Hooks.DragAndDrop = {
  mounted() {
    const trashBin = this.el;
    const options = document.querySelectorAll(".option");
    let correctOption = null;
    let dragging = true;

    this.pushEvent("get_correct_option");

    trashBin.addEventListener("dragstart", event => {
      event.dataTransfer.setData("text/plain", trashBin.id);

      const imgElement = event.target.querySelector('img');
      if (imgElement) {
        const dragIcon = document.createElement('img');
        dragIcon.src = imgElement.src;
        dragIcon.width = 80;
        dragIcon.height = 80;
        event.dataTransfer.setDragImage(dragIcon, 40, 40);
      }

      setTimeout(() => {
        event.target.classList.add("dragging");
      }, 0);
    });

    trashBin.addEventListener("dragend", event => {
      event.target.classList.remove("dragging");
    });

    options.forEach(option => {
      option.addEventListener("dragover", event => {
        event.preventDefault();
        option.classList.add("over");
      });

      option.addEventListener("dragleave", event => {
        option.classList.remove("over");
      });

      option.addEventListener("drop", event => {
        event.preventDefault();
        event.stopPropagation(); 
        option.classList.remove("over");
        const id = event.dataTransfer.getData("text/plain");

        if (!event.dataTransfer.dropHandled) {
          event.dataTransfer.dropHandled = true; 

          if (id === "trash-bin" && dragging) {
            if (option.id === correctOption) {
              document.getElementById("texthelpresposta").textContent = "Parabéns! Você acertou!";
              document.getElementById("texthelprespostatext").style.display = "block";
            } else {
              document.getElementById("texthelpresposta").textContent = "Ops! Resposta incorreta!";
              document.getElementById("texthelprespostatext").style.display = "block";
            }
            const trashBin = document.getElementById("trash-bin")
            trashBin.classList.remove("col-lg-12");
            trashBin.classList.add("col-lg-7");
            dragging = false;
            document.getElementById("texthelp").style.display = "block";
          }
        }
      });
    });
    
    this.handleEvent("correct_option", ({ option }) => {
      document.getElementById("trash-bin").style.display = "block";
      correctOption = option;
      console.log("Correct Option Received:", correctOption);
    });

    this.handleEvent("open_response", () => {
      document.getElementById("texthelpresposta").textContent = "Parabéns! Você acertou!";
      document.getElementById("texthelprespostatext").style.display = "block";
      const trashBin = document.getElementById("trash-bin")
      trashBin.classList.remove("col-lg-12");
      trashBin.classList.add("col-lg-7");
    });
  }
};

Hooks.PlayAudio = {
  mounted() {
    this.handleEvent("play_audio", () => {
      this.updateCache();
      this.playAudio();
    });
  },
  updated() {
    this.updateCache();
    this.playAudio();
  },
  playAudio() {
    let audioPlayer = document.getElementById("audio-player");
    if (audioPlayer) {
      audioPlayer.currentTime = 0; // Reinicia o áudio desde o início
      audioPlayer.play().catch(error => {
        console.error("Erro ao reproduzir o áudio:", error);
      });
    }
  },
  updateCache() {
    let audioPlayer = document.getElementById("audio-player");
    if (audioPlayer) {
      let source = audioPlayer.querySelector("source");
      let currentSrc = source.getAttribute("src");
      
      // Adiciona um parâmetro de cache-busting (timestamp)
      let newSrc = `${currentSrc.split("?")[0]}?cache_bust=${new Date().getTime()}`;
      
      source.setAttribute("src", newSrc);
      audioPlayer.load(); // Carrega o novo áudio com a URL atualizada
    }
  }
}

Hooks.SpeechToText = {
  mounted() {
    this.recognition = null;
    this.originalButtonText = this.el.innerHTML; // Armazena o texto original do botão

    // Inicializa o reconhecimento de voz se suportado
    if (!('webkitSpeechRecognition' in window)) {
      console.error("Speech recognition not supported in this browser.");
      return;
    }

    this.recognition = new webkitSpeechRecognition();
    this.recognition.lang = 'pt-BR'; // Defina o idioma para o reconhecimento
    this.recognition.continuous = false; // Não faz reconhecimento contínuo
    this.recognition.interimResults = false; // Não captura resultados intermediários

    // Quando o reconhecimento de voz finaliza, enviamos o texto
    this.recognition.onresult = (event) => {
      let transcript = event.results[0][0].transcript;
      console.log("Transcript:", transcript);

      // Envia o texto transcrito diretamente para o evento "send_message"
      this.pushEvent("send_message", { message: transcript });
    };

    // Lida com possíveis erros
    this.recognition.onerror = (event) => {
      console.error("Recognition error:", event.error);
      this.resetButtonText(); // Reseta o texto do botão em caso de erro
    };

    // Lida quando o reconhecimento é encerrado
    this.recognition.onend = () => {
      console.log("Speech recognition ended.");
      this.resetButtonText(); // Reseta o texto do botão quando o reconhecimento acaba
    };

    // Adiciona o listener de clique no botão
    this.el.addEventListener("click", () => {
      this.startRecognition();
      this.stopAudio(); // Para o áudio ao iniciar o reconhecimento
    });
  },
  startRecognition() {
    if (this.recognition) {
      this.el.innerHTML = "Fale agora..."; // Altera o texto do botão
      this.recognition.start();
      console.log("Speech recognition started.");
    }
  },
  stopRecognition() {
    if (this.recognition) {
      this.recognition.stop();
      console.log("Speech recognition stopped.");
      this.resetButtonText();
    }
  },
  resetButtonText() {
    // Restaura o texto original do botão
    this.el.innerHTML = this.originalButtonText;
  },
  stopAudio() {
    let audioPlayer = document.getElementById("audio-player");
    if (audioPlayer && !audioPlayer.paused) {
      audioPlayer.pause(); // Pausa o áudio se estiver tocando
      audioPlayer.currentTime = 0; // Opcional: Reinicia o áudio para o começo
      console.log("Audio stopped.");
    }
  }
}

export default Hooks;
