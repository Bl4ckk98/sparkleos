Name:           sparkle-os
Version:        1.0.0
Release:        1%{?dist}
Summary:        SparkleOS - Strumenti aziendali Sparkle integrati per Fedora

License:        Proprietary
URL:            https://github.com/bl4ckk/sparkleos

# Il tarball viene costruito dalla root del repo con:
#   tar czf sparkle-os-%%{version}.tar.gz \
#     --transform='s|^|sparkle-os-%%{version}/|' \
#     rpm-build/src/ assets/
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch
BuildRequires:  coreutils

# -------------------------------------------------------------------------
# Dipendenze runtime
# -------------------------------------------------------------------------
Requires:       python3
Requires:       python3-colorama
Requires:       python3-openpyxl
# Richiesto per la VPN IKEv1 PSK+XAuth via NetworkManager
Requires:       NetworkManager-libreswan

%description
Pacchetto unificato SparkleOS. Include:
  - sparkle-am-ssh          : SSH helper per nodi aziendali
  - sparkle-loop-checker    : Rilevamento loop TCAP su dump pcap
  - sparkle-netnumber-links : Analisi ed export link NetNumber SS7/Diameter
  - Sfondo aziendale        : /usr/share/backgrounds/sparkle/background.jpg
  - Tema Desktop Plasma     : /usr/share/plasma/desktoptheme/SparkleOS
  - Profilo VPN             : /etc/NetworkManager/system-connections/tisparkle.nmconnection

# =========================================================================
# %prep - estrai il tarball nella BUILD dir
# =========================================================================
%prep
%autosetup

# =========================================================================
# %build - nessuna compilazione (Python puro)
# =========================================================================
%build
# nothing to do

# =========================================================================
# %install - popola il buildroot
# =========================================================================
%install
# --- Binari in /usr/bin/ ---------------------------------------------------
install -d %{buildroot}%{_bindir}

for script in \
    sparkle-am-ssh \
    sparkle-loop-checker \
    sparkle-netnumber-links; do
  # NOTA: Assumiamo che il tarball contenga il path 'rpm-build/src/scripts/' intatto.
  # Se la fase di pacchettizzazione (CI) cambia la struttura, questo comando fallirà.
  install -m 0755 rpm-build/src/scripts/${script} \
    %{buildroot}%{_bindir}/${script}
done

# --- Modulo netnumber-links in /usr/share/sparkle-os/ ----------------------
install -d %{buildroot}%{_datadir}/sparkle-os/netnumber-links
cp -r rpm-build/src/netnumber-links/. \
  %{buildroot}%{_datadir}/sparkle-os/netnumber-links/

# --- Sfondo aziendale -------------------------------------------------------
install -d %{buildroot}%{_datadir}/backgrounds/sparkle
install -m 0644 assets/background.jpg \
  %{buildroot}%{_datadir}/backgrounds/sparkle/background.jpg

# --- Tema Plasma SparkleOS --------------------------------------------------
install -d %{buildroot}%{_datadir}/plasma/desktoptheme/SparkleOS
cp -rp theme/SparkleOS/* \
  %{buildroot}%{_datadir}/plasma/desktoptheme/SparkleOS/

# --- Profilo VPN NetworkManager/libreswan ----------------------------------
install -d %{buildroot}/etc/NetworkManager/system-connections
install -m 0600 assets/tisparkle.nmconnection \
  %{buildroot}/etc/NetworkManager/system-connections/tisparkle.nmconnection

# =========================================================================
# %files - lista file inclusi nel pacchetto
# =========================================================================
%files

%{_bindir}/sparkle-am-ssh
%{_bindir}/sparkle-loop-checker
%{_bindir}/sparkle-netnumber-links

%{_datadir}/sparkle-os/

%{_datadir}/backgrounds/sparkle/background.jpg

%{_datadir}/plasma/desktoptheme/SparkleOS/

%config(noreplace) /etc/NetworkManager/system-connections/tisparkle.nmconnection

# =========================================================================
# %changelog
# =========================================================================
%changelog
* Sat Mar 01 2026 bl4ckk <bl4ckk@tisparkle.com> - 1.0.0-1
- Prima release ufficiale SparkleOS (Fedora 42 / KDE)
- Integrati: am-ssh, loop-checker, route-adder, netnumber-links
- Aggiunto profilo VPN libreswan (tisparkle.nmconnection)
- Aggiunto sfondo aziendale
- Aggiunto tema Plasma aziendale (SparkleOS)
