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

# ---- Forza locale italiano nella sessione live ----
# livesys-late.service legge /etc/sysconfig/livesys e forza LANG;
# aggiungiamo la nostra impostazione affinché la sessione live sia italiana.
cat >> /etc/sysconfig/livesys << 'LIVESYS_LOCALE'

# SparkleOS - Forza italiano nella sessione live
LANG="it_IT.UTF-8"
LIVESYS_LOCALE

# Imposta locale e tastiera a livello di sistema (persistente)
echo 'LANG="it_IT.UTF-8"' > /etc/locale.conf
cat > /etc/vconsole.conf << 'VCONSOLE'
KEYMAP="it"
FONT="eurlatgr"
VCONSOLE
# localectl potrebbe non funzionare in chroot, usiamo i file sopra come fonte primaria
localectl set-locale LANG=it_IT.UTF-8 2>/dev/null || true
localectl set-keymap it 2>/dev/null || true
localectl set-x11-keymap it 2>/dev/null || true

# ---- Sfondo KDE (via /etc/skel) ----
# Metodo 1: Config statico di Plasma - letto direttamente da plasmashell al primo avvio
mkdir -p /etc/skel/.config/
cat > /etc/skel/.config/plasma-org.kde.plasma.desktop-appletsrc << 'PLASMARC'
[Containments][1]
activityId=
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.desktopcontainment
wallpaperplugin=org.kde.image

[Containments][1][Wallpaper][org.kde.image][General]
Image=file:///usr/share/backgrounds/sparkle/background.jpg
FillMode=1
PLASMARC

# Metodo 2: Script qdbus di fallback (per schermi aggiuntivi o aggiornamenti runtime)
mkdir -p /etc/skel/.config/autostart/
mkdir -p /etc/skel/.local/bin/

cat > /etc/skel/.local/bin/set-sparkle-wallpaper.sh << 'PLASMA_SCRIPT'
#!/bin/bash
# Attesa che plasmashell sia pronto
sleep 4
if [ "$XDG_SESSION_DESKTOP" = "KDE" ] || [ "$XDG_SESSION_DESKTOP" = "plasma" ]; then
  qdbus org.kde.plasmashell /PlasmaShell \
    org.kde.PlasmaShell.evaluateScript "
      var allDesktops = desktops();
      for (var i = 0; i < allDesktops.length; i++) {
        var d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
        d.writeConfig('Image', 'file:///usr/share/backgrounds/sparkle/background.jpg');
      }
    " 2>/dev/null || true
fi
PLASMA_SCRIPT
chmod +x /etc/skel/.local/bin/set-sparkle-wallpaper.sh

cat > /etc/skel/.config/autostart/set-sparkle-wallpaper.desktop << 'EOF'
[Desktop Entry]
Exec=/bin/bash -c "if [ -f ~/.local/bin/set-sparkle-wallpaper.sh ]; then ~/.local/bin/set-sparkle-wallpaper.sh; fi"
Name=Set SparkleOS Wallpaper
Type=Application
X-KDE-AutostartScript=true
EOF

%end
