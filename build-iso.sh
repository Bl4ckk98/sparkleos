#!/bin/bash
# ============================================================
# SparkleOS - Build ISO
# Richiede: root, lorax, anaconda-tui (su Fedora host)
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/output"
DNF_CACHE_DIR="${SCRIPT_DIR}/.dnf-cache"
TMP_DIR="${SCRIPT_DIR}/tmp"
LOG_FILE="${SCRIPT_DIR}/livemedia.log"
START_TIME=$(date +%s)

# ------ Colori -----------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'

info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERRORE]${RESET} $*" >&2; }

# ------ Container execution fallback ---------------------------
# Se non ci sono i loop devices disponibili (siamo in un container rootless) 
# o manca livemedia-creator/lorax, rilanciamoci tramite podman con privilegi host
if [ ! -e /dev/loop-control ] || ! command -v livemedia-creator &>/dev/null; then
  warn "L'ambiente corrente manca di privilegi completi o pacchetti necessari."
  info "Avvio build in container podman privilegiato..."
  
  # Determina il container engine (podman o docker)
  CONTAINER_CMD=""
  if command -v podman &>/dev/null; then
    CONTAINER_CMD="podman"
  elif command -v docker &>/dev/null; then
    CONTAINER_CMD="docker"
  else
    error "Né Podman né Docker sono installati nell'host. Impossibile avviare il container di build."
    exit 1
  fi

  # Aggiungi sudo se necessario (docker spesso lo richiede se l'utente non è nel gruppo docker)
  if [ "$EUID" -ne 0 ] && command -v sudo &>/dev/null; then
    CONTAINER_CMD="sudo $CONTAINER_CMD"
  fi
  
  info "Engine rilevato: $CONTAINER_CMD"
  
  ############################################################
  # Salviamo i log di Anaconda in una directory persistente
  ############################################################
  LOG_DIR="${SCRIPT_DIR}/logs/anaconda"
  rm -rf "${LOG_DIR}"
  mkdir -p "${LOG_DIR}"
  
  exec $CONTAINER_CMD run --rm -it \
    --name "sparkleos-builder-$$" \
    --privileged \
    --security-opt label=disable \
    -v /dev:/dev \
    -v "${LOG_DIR}:/var/log/anaconda" \
    -v "${SCRIPT_DIR}:/workspace" \
    -w /workspace \
    quay.io/fedora/fedora:42 \
    bash -c "
      echo '=> Installazione dipendenze per livemedia-creator...'
      dnf install -y lorax anaconda-tui pykickstart dbus-daemon > /dev/null
      
      echo '=> Avvio dbus-daemon...'
      mkdir -p /var/run/dbus
      dbus-daemon --system --fork
      dbus-daemon --session --fork --address=unix:path=/tmp/dbus-session
      export DBUS_SESSION_BUS_ADDRESS=unix:path=/tmp/dbus-session
      
      echo '=> Avvio build...'
      ./build-iso.sh
    "
  # Lo script si ferma qui se rilanciato con exec
fi

# ------ Root check -------------------------------------------
if [ "$EUID" -ne 0 ]; then
  error "Questo script deve essere eseguito come root (usa sudo)."
  exit 1
fi

# ------ Dipendenze -------------------------------------------
for cmd in livemedia-creator anaconda; do
  if ! command -v "$cmd" &>/dev/null; then
    error "Comando '$cmd' non trovato anche dopo installazione in container."
    exit 1
  fi
done

# ------ Prepara directory output -----------------------------
info "Preparo directory di output: ${OUTPUT_DIR}"
rm -rf "${OUTPUT_DIR}"
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

# ------ Cache DNF persistente --------------------------------
mkdir -p "${DNF_CACHE_DIR}"
if [ -d "${DNF_CACHE_DIR}" ] && [ "$(ls -A "${DNF_CACHE_DIR}" 2>/dev/null)" ]; then
  success "Cache DNF trovata in ${DNF_CACHE_DIR} - i pacchetti già scaricati verranno riutilizzati."
else
  warn "Prima build: la cache DNF verrà popolata in ${DNF_CACHE_DIR}."
fi

# ------ Kickstart check --------------------------------------
if [ ! -f "${SCRIPT_DIR}/sparkle-os.ks" ]; then
  error "Kickstart non trovato: ${SCRIPT_DIR}/sparkle-os.ks"
  exit 1
fi

echo ""
echo -e "${BOLD}============================================================${RESET}"
echo -e "${BOLD}  SparkleOS ISO Build - $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
echo -e "${BOLD}============================================================${RESET}"
echo ""
info "Kickstart:  ${SCRIPT_DIR}/sparkle-os.ks"
info "Output:     ${OUTPUT_DIR}/"
info "Log:        ${LOG_FILE}"
info "Cache DNF:  ${DNF_CACHE_DIR}/"
echo ""

# ------ Appiattisci il kickstart (risolve tutti gli %include) --------
KS_FLAT="${TMP_DIR}/sparkle-os-flat.ks"
info "Appiattimento kickstart con ksflatten..."
if ! command -v ksflatten &>/dev/null; then
  error "ksflatten non trovato. Installa: dnf install pykickstart"
  exit 1
fi
ksflatten --config "${SCRIPT_DIR}/sparkle-os.ks" -o "${KS_FLAT}"
success "Kickstart appiattito in: ${KS_FLAT}"
echo ""

# ------ Lancia livemedia-creator -----------------------------
livemedia-creator \
  --ks="${KS_FLAT}" \
  --no-virt \
  --resultdir="${OUTPUT_DIR}" \
  --project="SparkleOS" \
  --make-iso \
  --iso-only \
  --volid="SparkleOS-1.0.0" \
  --extra-boot-args="inst.lang=it_IT.UTF-8 inst.keymap=it" \
  --releasever=42 \
  --image-size=9000 \
  --logfile="${LOG_FILE}" \
  --tmp="${TMP_DIR}" &

LMC_PID=$!
info "livemedia-creator avviato (PID: ${LMC_PID})"
echo ""

# ------ Segui i log in tempo reale ---------------------------
# Aspetta che il log venga creato
sleep 3
if [ -f "${LOG_FILE}" ]; then
  info "=== Log in tempo reale (Ctrl+C per staccare il tail, il build continua) ==="
  echo ""
  tail -f "${LOG_FILE}" &
  TAIL_PID=$!
fi

# Attendi la fine del processo
wait "${LMC_PID}"
LMC_EXIT=$?

# Ferma il tail
[ -n "${TAIL_PID:-}" ] && kill "${TAIL_PID}" 2>/dev/null || true
echo ""

# ------ Risultato --------------------------------------------
END_TIME=$(date +%s)
DURATION=$(( END_TIME - START_TIME ))
MINUTES=$(( DURATION / 60 ))
SECONDS=$(( DURATION % 60 ))

if [ "${LMC_EXIT}" -eq 0 ]; then
  ISO_FILE=$(find "${OUTPUT_DIR}" -name "*.iso" 2>/dev/null | head -1)
  echo ""
  echo -e "${BOLD}============================================================${RESET}"
  success "Build completata in ${MINUTES}m ${SECONDS}s!"
  if [ -n "${ISO_FILE}" ]; then
    ISO_SIZE=$(du -sh "${ISO_FILE}" | cut -f1)
    success "ISO:  ${ISO_FILE} (${ISO_SIZE})"
    echo ""
    info "Test rapido in QEMU:"
    echo "  qemu-system-x86_64 -cdrom \"${ISO_FILE}\" -m 4G -boot d -enable-kvm"
  fi
  echo -e "${BOLD}============================================================${RESET}"
  echo ""
else
  echo ""
  echo -e "${BOLD}============================================================${RESET}"
  error "Build fallita dopo ${MINUTES}m ${SECONDS}s. Controlla: ${LOG_FILE}"
  echo -e "${BOLD}============================================================${RESET}"
  echo ""
  exit 1
fi
