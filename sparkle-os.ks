# ============================================================
# SparkleOS - Kickstart per Fedora 42 KDE
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

# ------ Override utente live SparkleOS ----------------------
user --name=liveuser --gecos="Live User" --password=liveuser --plaintext --groups=wheel

# ------ Override dimensione partizione ----------------------
part / --size=8192 --fstype=ext4

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

# ---- Sessione livesys: KDE ----
sed -i 's/^livesys_session=.*/livesys_session="kde"/' /etc/sysconfig/livesys

# ---- Sfondo KDE per nuovi utenti (via /etc/skel) ----
mkdir -p /etc/skel/.config/plasma-workspace/env

cat > /etc/skel/.config/plasma-workspace/env/set-wallpaper.sh << 'PLASMA_SCRIPT'
#!/bin/bash
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
chmod +x /etc/skel/.config/plasma-workspace/env/set-wallpaper.sh

%end
