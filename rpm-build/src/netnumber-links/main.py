#!/usr/bin/env python3
"""
NetNumber Link Parser
Legge i file (es. milano.txt e catania.txt) dalla cartella configs
e produce un file Excel con l'output. Strutturato in modo modulare
per supportare SS7 e futura integrazione col diameter.
"""

import os
import sys
from openpyxl import Workbook

# Import dei moduli
from parsers.ss7 import process_ss7_file
from exporters.excel import write_sheet

SS7_COLUMNS = [
    "Nome Link",
    "Descrizione",
    "Istanza",
    "Tipo",
    "SLC",
    "Endpoint Locale",
    "Endpoint Remoto"
]

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    configs_dir = os.path.join(script_dir, "configs")

    # Mappa file SS7 previsti
    ss7_files = {
        "CATANIA": os.path.join(configs_dir, "catania.txt"),
        "MILANO": os.path.join(configs_dir, "milano.txt"),
    }

    # Controllo che almeno un file esista
    missing = [name for name, path in ss7_files.items() if not os.path.exists(path)]
    if len(missing) == len(ss7_files):
        print(f"[ERRORE] Nessun file di configurazione trovato in: {configs_dir}")
        print("Assicurati che i file (es. catania.txt, milano.txt) siano presenti.")
        sys.exit(1)
    elif missing:
        print(f"[AVVISO] File mancanti: {', '.join(f'{n}.txt'.lower() for n in missing)}")

    # Inizializza Workbook openpyxl
    wb = Workbook()
    wb.remove(wb.active)  # Rimuove il foglio di default

    # Elaborazione SS7
    for location, filepath in ss7_files.items():
        if not os.path.isfile(filepath):
            continue
            
        print(f"[INFO] Elaborazione SS7 {os.path.basename(filepath)} ...")
        
        # Parsing blocchi SS7 e creazione righe
        rows = process_ss7_file(filepath)
        
        # Foglio dedicato (es. "MILANO")
        ws = wb.create_sheet(title=location)
        write_sheet(ws, rows, SS7_COLUMNS)
        
        print(f"[INFO]   -> {len(rows)} link SS7 trovati per {location}")

    # TODO: Inserire in futuro l'elaborazione dei blocchi Diameter qui

    # Salvataggio
    output_path = os.path.join(script_dir, "NetNumber_Links.xlsx")
    wb.save(output_path)
    print(f"\n[OK] File Excel salvato in: {output_path}")

if __name__ == "__main__":
    main()
