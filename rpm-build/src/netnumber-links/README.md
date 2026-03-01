# NetNumber SS7 Link Parser

Questo strumento in Python analizza le configurazioni dei link SS7 di NetNumber e genera un file Excel (`.xlsx`) ben formattato e strutturato con i dettagli dei link estratti.

## Cosa fa lo script

Lo script `main.py` legge due file di testo (tipicamente gli export di configurazione dei nodi):
- `milano.txt`
- `catania.txt`

Analizza i blocchi di testo relativi a link, connessioni e binding SS7, incrociando i dati per determinare ed estrarre le seguenti informazioni che scriverà nel file `output_links.xlsx` suddividendole in due fogli di lavoro (MILANO e CATANIA):
- Nome Link
- Istanza (es. itu, ansi)
- Tipo (es. m3ua, m2pa)
- SLC
- Endpoint Locale (IP e Porta)
- Endpoint Remoto (IP e Porta)

---

## Come scaricare il progetto

Puoi ottenere i file del progetto in due modi:

### Opzione 1: Clonare la Repository (per chi usa Git)
Apri il terminale e digita:
```bash
git clone <URL_DELLA_REPOSITORY>
cd netnumber-links
```

### Opzione 2: Scaricare come file ZIP
1. Scarica il codice sorgente come archivio `.zip` (dal pulsante verde "Code" -> "Download ZIP").
2. Estrai il contenuto del file ZIP in una cartella a tua scelta sul tuo PC.
3. Apri la cartella che hai appena estratto (quella contenente i file `main.py`, `run.bat`, ecc.).

---

## Istruzioni per l'uso

Lo script è progettato per essere "plug and play", senza che tu debba preoccuparti manualmente di installare pacchetti o creare ambienti virtuali.

### 1. Posizionare correttamente i file
Affinché lo script trovi i dati, devi inserire i file di origine nella cartella giusta:
1. Assicurati che all'interno della cartella principale del progetto ci sia una cartella chiamata `configs` (se non c'è, creala).
2. Sposta al suo interno i due file da analizzare, rinominandoli *esattamente* così:
   - `milano.txt`
   - `catania.txt`

### 2. Avviare lo script
Per facilitare il lavoro sono stati creati due file di lancio che si occupano di installare i requisiti al primo avvio.

- **Su Windows:**
  Fai semplicemente **doppio clic** sul file **`run.bat`**. 
  *(Nota: Al primo avvio impiegherà qualche secondo in più perché creerà l'ambiente virtuale scaricando il necessario, comparirà la finestra del terminale).*

- **Su Linux / macOS:**
  Apri il terminale nella cartella del progetto e rendi lo script eseguibile (solo la prima volta), poi avvialo:
  ```bash
  chmod +x run.sh
  ./run.sh
  ```

### 3. Recuperare i risultati
Se tutto è andato a buon fine, il terminale mostrerà un messaggio di successo e troverai un nuovo file chiamato **`output_links.xlsx`** all'interno della cartella principale del progetto. Questo file conterrà tutti i dati estratti pronti per essere filtrati ed analizzati su Excel.

---

## Requisiti (per uso manuale)
Se desideri far girare lo script ignorando i file `run.bat` o `run.sh` avrai bisogno di:
- **Python 3**
- Le dipendenze elencate in `requirements.txt` (nello specifico la libreria `openpyxl`). 

Puoi installarle in questo modo:
```bash
python -m venv venv
source venv/bin/activate  # oppure venv\Scripts\activate su Windows
pip install -r requirements.txt
python main.py
```
