# ============================================================
# SparkleOS — Kickstart per Fedora 42 KDE
# Genera una ISO personalizzata con pacchetti e VPN aziendali
# ============================================================

# ------ Lingua e tastiera ------------------------------------
lang it_IT.UTF-8
keyboard --vckeymap=it --xlayouts='it'
timezone Europe/Rome --utc

# ------ Rete -------------------------------------------------
network --bootproto=dhcp --device=link --activate
network --hostname=sparkle-workstation

# ------ Bootloader -------------------------------------------
bootloader --location=mbr

# ------ Partizionamento (minimale per ISO live) ---------------
clearpart --all --initlabel
autopart --type=plain

# ------ Modalità grafica e DE --------------------------------
xconfig --startxonboot
skipx

# ============================================================
# REPOSITORY
# ============================================================

# Fedora 42 — repo ufficiale
repo --name=fedora \
     --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-42&arch=$basearch

repo --name=fedora-updates \
     --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f42&arch=$basearch

# Copr bl4ckk/sparkle-os
# Assicurati di aver abilitato il progetto su https://copr.fedorainfracloud.org/coprs/bl4ckk/sparkle-os/
repo --name=copr-sparkle-os \
     --baseurl=https://download.copr.fedorainfracloud.org/results/bl4ckk/sparkle-os/fedora-42-x86_64/

# ============================================================
# PACCHETTI
# ============================================================
%packages
# Pacchetto aziendale SparkleOS (dal Copr)
sparkle-os

# Tool di base
vim
git
htop
gnome-extensions-app

# Dipendenze Python per gli script SparkleOS
python3
python3-colorama
python3-tkinter

# VPN Shrew Soft
shrew

# KDE Plasma — DE principale SparkleOS
@kde-desktop-environment

%end

# ============================================================
# %post — Configurazione post-installazione
# ============================================================
%post --erroronfail

# ---- Sfondo KDE per nuovi utenti (via /etc/skel) ---------------
# Ogni nuovo utente creato sul sistema erediterà questo wallpaper al primo login.
mkdir -p /etc/skel/.config/plasma-workspace/env

cat > /etc/skel/.config/plasma-workspace/env/set-wallpaper.sh << 'PLASMA_SCRIPT'
#!/bin/bash
# Applica lo sfondo SparkleOS alla sessione KDE Plasma corrente
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
