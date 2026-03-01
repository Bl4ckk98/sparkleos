#!/bin/bash
# Script per generare l'ISO di SparkleOS

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/output"

if [ "$EUID" -ne 0 ]; then
  echo "Questo script deve essere eseguito come root (usa sudo)."
  exit 1
fi

# Verifica accesso ai loop devices (non disponibili in container non privilegiati)
if ! losetup --find &>/dev/null; then
  echo ""
  echo "ERRORE: loop devices non accessibili. Stai eseguendo in un container non privilegiato (es. distrobox)?"
  echo ""
  echo "Soluzione — esegui dalla shell HOST con podman:"
  echo ""
  echo "  podman run --rm --privileged \\"
  echo "    -v ${SCRIPT_DIR}:/project:z \\"
  echo "    -w /project \\"
  echo "    fedora:42 bash -c \"dnf install -y lorax anaconda-tui && bash build-iso.sh\""
  echo ""
  exit 1
fi

echo "Avvio della build per l'ISO di SparkleOS..."

# Pulisce la directory di destinazione se esiste
if [ -d "${OUTPUT_DIR}" ]; then
  echo "Rimuovo la directory di output precedente (${OUTPUT_DIR})..."
  rm -rf "${OUTPUT_DIR}"
fi

# Esegui livemedia-creator per creare l'ISO
if livemedia-creator \
  --ks="${SCRIPT_DIR}/sparkle-os.ks" \
  --no-virt \
  --resultdir="${OUTPUT_DIR}" \
  --project="SparkleOS" \
  --make-iso \
  --volid="SparkleOS-1.0" \
  --iso-only \
  --releasever=42; then

  echo "Build completata con successo! L'ISO si trova in: ${OUTPUT_DIR}/"
else
  echo "Errore durante la build dell'ISO."
  exit 1
fi
