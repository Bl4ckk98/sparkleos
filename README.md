<div align="center">
  <img src="https://upload.wikimedia.org/wikipedia/commons/8/83/Telecom_Italia_Sparkle_logo_%282016-present%29.svg" alt="Telecom Italia Sparkle Logo" width="300" />
</div>

# 🌟 SparkleOS

![OS](https://img.shields.io/badge/OS-Fedora%2042-blue)
![Desktop Environment](https://img.shields.io/badge/Desktop_Environment-KDE_Plasma-informational?logo=kde)

Benvenuto in **SparkleOS**, il sistema operativo aziendale ottimizzato per offrire un ambiente di lavoro fluido, sicuro e pre-configurato. 
Basato su **Fedora 43** con ambiente desktop **KDE Plasma**, SparkleOS include sin dal primo avvio tutti gli strumenti essenziali per la produttività aziendale, comprese le configurazioni di rete (es. VPN) e le utility base di sistema.

---

## 🚀 Installazione Iniziale

Per installare SparkleOS sul computer aziendale, segui questi passaggi:

1. **Richiedi la ISO:** Ottieni l'immagine ISO dagli sviluppatori e creane una chiavetta USB avviabile (utilizzando strumenti come *Rufus*, *Fedora Media Writer* o *BalenaEtcher*).
2. **Avvia da USB:** Inserisci la chiavetta nel PC e procedi con l'avvio del sistema (Boot from USB).
3. **Installa:** Segui le istruzioni a schermo per completare l'installazione. L'installer configurerà automaticamente il sistema base.
4. **Pronto all'uso:** Al primo avvio, l'ambiente di lavoro sarà già operativo: troverai lo sfondo aziendale impostato e i profili di rete aziendali pre-configurati.

---

## 🛠️ Compilazione della ISO (Per Sviluppatori)

Per costruire autonomamente l'immagine ISO di SparkleOS:

```bash
sudo ./build-iso.sh
```

### Risoluzione dei problemi e Log

Durante o dopo la build, puoi monitorare il processo e analizzare i log generati dal container di installazione:

```bash
# Log iniziali di Anaconda
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) cat /tmp/anaconda.log

# Verifica dei processi in esecuzione di Anaconda
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) ps aux | grep anaconda

# Log di DNF (installazione dei pacchetti)
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) cat /tmp/dnf.log

# Log di packaging
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) cat /tmp/packaging.log

# Log del journal completo del container
sudo podman exec -it $(sudo podman ps -q -f name=sparkleos-builder) journalctl -n 100
```

---

## 🔄 Ricevere gli Aggiornamenti

Il grande vantaggio di SparkleOS è la sua capacità di **aggiornarsi in modo invisibile e continuo**. 
Non è mai necessario scaricare file manualmente o reinstallare il sistema per ottenere le nuove versioni dei tool aziendali o delle configurazioni modificate.

- **Rilevamento Automatico:** Quando gli sviluppatori rilasciano un aggiornamento, il tuo computer lo rileverà in automatico assieme ai normali aggiornamenti di sistema di Fedora.
- **Notifiche:** Riceverai una notifica nell'angolo in basso a destra del desktop tramite **Discover**, il software center di sistema.
- **Installazione Semplice:** Ti basterà cliccare su **"Aggiorna"** o, in alternativa, eseguire da terminale:
  ```bash
  sudo dnf upgrade
  ```
- **Zero Interruzioni:** Le nuove configurazioni e i nuovi tool saranno immediatamente disponibili, spesso senza alcun bisogno di riavviare il PC.

---

## 📞 Supporto

Per qualsiasi problema, segnalazione di bug o richiesta di assistenza, ti invitiamo a contattare gli sviluppatori.