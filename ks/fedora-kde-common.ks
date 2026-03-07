
%packages
# install env-group to resolve RhBug:1891500
@^kde-desktop-environment

@firefox
@kde-apps
@kde-media
# Ensure we have Anaconda initial setup using kwin
@kde-spin-initial-setup
@libreoffice
# add libreoffice-draw and libreoffice-math (pagureio:fedora-kde/SIG#103)
libreoffice-draw
libreoffice-math

fedora-release-kde

# drop tracker stuff pulled in by gtk3 (pagureio:fedora-kde/SIG#124)
-tracker-miners
-tracker

# Not needed on desktops. See: https://pagure.io/fedora-kde/SIG/issue/566
-mariadb-server-utils

# Exclude KDE PIM suite and related unneeded background services
-akonadi-server
-mariadb-server
-mariadb
-mariadb-connector-c

### The KDE-Desktop

# fedora-specific packages
plasma-welcome-fedora

### fixes

# minimal localization support - allows installing the kde-l10n-* packages
kde-l10n

# Additional packages that are not default in kde-* groups, but useful
fuse
mediawriter

### space issues

## avoid serious bugs by omitting broken stuff

%end
