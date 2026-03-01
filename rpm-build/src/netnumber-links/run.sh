#!/bin/bash
# Launcher per main.py con Virtual Environment
echo "Inizializzazione..."
# Controlla se esiste l'ambiente virtuale
if [ ! -d "venv" ]; then
    echo "Creazione dell'ambiente virtuale al primo avvio..."
    python3 -m venv venv
    
    echo "Installazione delle dipendenze (richiesto solo la prima volta)..."
    source venv/bin/activate
    pip install -r requirements.txt
else
    source venv/bin/activate
fi
echo "Avvio main.py..."
python3 main.py
if [ $? -ne 0 ]; then
    echo ""
    echo "[ERRORE] Lo script ha riscontrato un problema."
    read -p "Premi Invio per continuare..."
    exit 1
fi
echo ""
read -p "Premi Invio per continuare..."