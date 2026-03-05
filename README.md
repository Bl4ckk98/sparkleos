# SparkleOS

Benvenuto in **SparkleOS**, il sistema operativo aziendale ottimizzato per offrire un ambiente di lavoro fluido, sicuro e pre-configurato basato su Fedora 42.
SparkleOS è basato su Fedora (con ambiente grafico KDE Plasma) e include tutti gli strumenti e le configurazioni necessarie per iniziare subito a lavorare, incluse le connessioni VPN aziendali e le utily di base.

# 🚀 Installazione iniziale

Per installare SparkleOS sul tuo computer aziendale:
1. Richiedi la ISO agli sviluppatori e inseriscila in una chiavetta USB.
2. Inserisci la chiavetta nel PC e avvia il sistema da USB.
3. Segui le istruzioni a schermo per completare l'installazione. L'installer configurerà il sistema base in automatico.
4. Al primo avvio, troverai il tuo ambiente di lavoro già pronto all'uso: lo sfondo aziendale impostato e i profili di rete (come la VPN) già pre-configurati.

# Buildare la ISO

sudo ./build-iso.sh

# Per i log

## Log iniziali di Anaconda
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) cat /tmp/anaconda.log
## Vedi se il processo anaconda è ancora vivo
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) ps aux | grep anaconda
## Guarda il log di DNF (installazione pacchetti)
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) cat /tmp/dnf.log
## Guarda il log di packaging
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) cat /tmp/packaging.log
## Oppure il journal completo
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) journalctl -n 100

# 🔄 Ricevere gli Aggiornamenti

Il grande vantaggio di SparkleOS è che **si aggiorna da solo in modo invisibile e continuo**. 
Non dovrai mai scaricare file manualmente o reinstallare il sistema per ottenere le nuove versioni dei tool aziendali o delle configurazioni.

- Quando gli sviluppatori rilasciano un aggiornamento, il tuo computer lo rileverà automaticamente insieme ai normali aggiornamenti di sistema di Fedora.
- Riceverai una notifica nell'angolo in basso a destra (tramite **Discover**, il software center di sistema).
- Ti basterà cliccare su "Aggiorna" (o in alternativa, usare il comando `sudo dnf upgrade` da terminale).
- Le nuove configurazioni e i nuovi tool saranno immediatamente disponibili, senza stress e nella maggior parte dei casi senza bisogno di riavviare il PC.

Per qualsiasi problema o richiesta di assistenza, contatta gli sviluppatori.

- Francesco e Matteo

