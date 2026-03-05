# ============================================================
# SparkleOS - Kickstart per Fedora KDE
# ============================================================
# Basato sulla gerarchia ufficiale Fedora KDE Spin.
# I file base nella cartella ks/ gestiscono:
#   - setup livesys (livesys.service, livesys-late.service)
#   - dracut-live
#   - pacchetti KDE Plasma
#   - pulizia post-install standard
# Qui definiamo SOLO le personalizzazioni SparkleOS.
# ============================================================

%include ks/fedora-live-kde-base.ks
%include ks/fedora-live-minimization.ks

# ------ Override lingua/tastiera/timezone (sovrascrivono en_US) --
lang it_IT.UTF-8
keyboard --vckeymap=it --xlayouts='it'
timezone Europe/Rome --utc

# ------ Override: shutdown -> reboot per la live --
reboot

# ------ Override dimensione partizione (DVD payload) --------
# Sovrascrive la part / --size=5120 definita in fedora-live-base.ks
# Valore allineato allo standard fedora-live-kde.ks (9000 MB)
part / --size=9000

# ============================================================
# PACCHETTI SPARKLE-OS
# ============================================================
%packages
# Pacchetto aziendale SparkleOS (dal Copr)
sparkle-os


# Tool di base
vim
nano
git
htop
curl
wget
bash-completion
net-tools

# Localizzazione italiana
glibc-langpack-it
langpacks-it

# Dipendenze Python per gli script SparkleOS
python3-colorama
python3-openpyxl

# VPN IKEv1 PSK+XAuth via NetworkManager
NetworkManager-libreswan

%end

# ============================================================
# %post - Personalizzazioni SparkleOS
# ============================================================
%post --erroronfail

# ---- Fix dracut-ng bug #1240 (get_url_handler: command not found) ----
# Upstream fix: https://github.com/dracut-ng/dracut-ng/commit/f399a28
# Rimuove la chiamata stray a get_url_handler in parse-livenet.sh
# che viene eseguita prima che url-lib.sh venga caricata.
# Può essere rimosso quando dracut >= 106 con il fix sarà in Fedora 42.
LIVENET_PARSE="/usr/lib/dracut/modules.d/90livenet/parse-livenet.sh"
if [ -f "$LIVENET_PARSE" ] && grep -q '^get_url_handler$' "$LIVENET_PARSE"; then
    sed -i '/^get_url_handler$/d' "$LIVENET_PARSE"
    echo "INFO: Patched dracut livenet module (bug #1240)"
fi

# ---- Fix Fedora 42: systemd-sysroot-fstab-check mancante in initramfs ----
# Il binario esiste nel sistema ma dracut non lo include nell'initramfs,
# causando il fallimento di initrd-parse-etc.service → emergency shell.
# La config dracut da sola non basta: bisogna rigenerare l'initramfs.
FSTAB_CHECK="/usr/lib/systemd/systemd-sysroot-fstab-check"
if [ -f "$FSTAB_CHECK" ]; then
    mkdir -p /etc/dracut.conf.d
    echo "install_items+=\" $FSTAB_CHECK \"" > /etc/dracut.conf.d/99-sysroot-fstab-check.conf
    echo "INFO: Added dracut config to include systemd-sysroot-fstab-check"
    # Rigenera l'initramfs per includere il binario nella live ISO
    KERNEL_VER=$(ls /lib/modules/ | sort -V | tail -1)
    if [ -n "$KERNEL_VER" ]; then
        dracut --force /boot/initramfs-${KERNEL_VER}.img "$KERNEL_VER"
        echo "INFO: Regenerated initramfs for kernel $KERNEL_VER"
    fi
fi

# ---- Sessione livesys: KDE ----
sed -i 's/^livesys_session=.*/livesys_session="kde"/' /etc/sysconfig/livesys

# ---- Branding di sistema: SparkleOS 1.0.0 --------------------
# Sovrascriviamo /etc/os-release in modo che il sistema (e l'installer)
# si identifichino come SparkleOS invece che Fedora.
if [ -f /etc/os-release ]; then
  cp /etc/os-release /etc/os-release.fedora || true
fi

cat > /etc/os-release << 'OSREL'
NAME="SparkleOS"
VERSION="1.0.0 (KDE Plasma)"
ID=sparkleos
ID_LIKE=fedora
VERSION_ID="1.0.0"
PRETTY_NAME="SparkleOS 1.0.0 (KDE Plasma)"
ANSI_COLOR="0;34"
HOME_URL="https://github.com/bl4ckk/sparkleos"
BUG_REPORT_URL="https://github.com/bl4ckk/sparkleos/issues"
LOGO=fedora-kde
OSREL

# ---- Sfondo KDE (Plasma e SDDM) ----
# Configurazione di SDDM (Schermata di Login)
# Assicuriamoci che la directory esista per il tema
mkdir -p /usr/share/sddm/themes/breeze/
cat > /usr/share/sddm/themes/breeze/theme.conf.user << 'SDDM_CONF'
[General]
background=/usr/share/backgrounds/sparkle/background.jpg
type=image
SDDM_CONF

# Configurazione di Plasma (Sfondo del Desktop e Tema)
# Impostiamo il tema desktop SparkleOS come default a livello di sistema
mkdir -p /etc/xdg/
cat > /etc/xdg/plasmarc << 'PLASMARC_SYS'
[Theme]
name=SparkleOS
PLASMARC_SYS

# Plasma esegue tutti gli script .js in questa directory una sola volta per utente.
# Perfetto per liveuser e per il primo avvio del sistema installato.
mkdir -p /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/
cat > /usr/share/plasma/shells/org.kde.plasma.desktop/contents/updates/99-sparkle-wallpaper.js << 'PLASMA_JS'
var allDesktops = desktops();
for (var i = 0; i < allDesktops.length; i++) {
    var d = allDesktops[i];
    d.wallpaperPlugin = "org.kde.image";
    d.currentConfigGroup = Array("Wallpaper", "org.kde.image", "General");
    d.writeConfig("Image", "file:///usr/share/backgrounds/sparkle/background.jpg");
    d.writeConfig("FillMode", "0");
}
PLASMA_JS

# ---- Aggiunta Repository COPR per SparkleOS ----
mkdir -p /etc/yum.repos.d/
cat > /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:bl4ckk:sparkleos.repo << 'EOF_REPO'
[copr:copr.fedorainfracloud.org:bl4ckk:sparkleos]
name=Copr repo for sparkleos owned by bl4ckk
baseurl=https://download.copr.fedorainfracloud.org/results/bl4ckk/sparkleos/fedora-$releasever-$basearch/
type=rpm-md
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://download.copr.fedorainfracloud.org/results/bl4ckk/sparkleos/pubkey.gpg
repo_gpgcheck=0
enabled=1
enabled_metadata=1
EOF_REPO

%end

# ============================================================
# %post --nochroot - Configurazione sistema installato
# ============================================================
%post --nochroot --erroronfail

# Percorso root del sistema appena installato
SYSROOT="/mnt/sysimage"

# Branding SparkleOS anche nel sistema installato
if [ -f "${SYSROOT}/etc/os-release" ]; then
  cp "${SYSROOT}/etc/os-release" "${SYSROOT}/etc/os-release.fedora" || true
fi

cat > "${SYSROOT}/etc/os-release" << 'OSREL_CHROOT'
NAME="SparkleOS"
VERSION="1.0.0 (KDE Plasma)"
ID=sparkleos
ID_LIKE=fedora
VERSION_ID="1.0.0"
PRETTY_NAME="SparkleOS 1.0.0 (KDE Plasma)"
ANSI_COLOR="0;34"
HOME_URL="https://github.com/bl4ckk/sparkleos"
BUG_REPORT_URL="https://github.com/bl4ckk/sparkleos/issues"
LOGO=fedora-kde
OSREL_CHROOT

%end
