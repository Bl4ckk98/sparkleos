#!/bin/bash
# Script per generare l'ISO di SparkleOS

if [ "$EUID" -ne 0 ]; then
  echo "Questo script deve essere eseguito come root (usa sudo)."
  exit 1
fi

echo "Avvio della build per l'ISO di SparkleOS..."
echo "Assicurati di aver installato i prerequisiti: sudo dnf install -y lorax anaconda-tui"

# Esegui livemedia-creator per creare l'ISO
livemedia-creator \
  --ks=./sparkle-os.ks \
  --no-virt \
  --resultdir=/var/lmc \
  --project="SparkleOS" \
  --make-iso \
  --volid="SparkleOS-1.0" \
  --iso-only \
  --releasever=42

echo "Build completata. L'ISO si trova nel percorso /var/lmc/"
