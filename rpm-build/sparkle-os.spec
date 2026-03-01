Name:           sparkle-os
Version:        1.0.0
Release:        1%{?dist}
Summary:        SparkleOS - Strumenti aziendali TISpark integrati per Fedora

License:        Proprietary
URL:            https://github.com/bl4ckk/sparkleos

# Il tarball viene costruito dalla root del repo con:
#   tar czf sparkle-os-%%{version}.tar.gz \
#     --transform='s|^|sparkle-os-%%{version}/|' \
#     rpm-build/src/ assets/
Source0:        %{name}-%{version}.tar.gz

BuildArch:      noarch

# -------------------------------------------------------------------------
# Dipendenze runtime
# -------------------------------------------------------------------------
Requires:       python3
Requires:       python3-colorama
Requires:       python3-tkinter
# customtkinter non è nei repo Fedora; installalo con:
#   pip install --user customtkinter
# oppure aggiungi il tuo Copr secondario che lo fornisce.
# Shrew Soft VPN client (ike)
Requires:       shrew

%description
Pacchetto unificato SparkleOS. Include:
  - sparkle-am-ssh          : SSH helper per nodi aziendali
  - sparkle-loop-checker    : Rilevamento loop TCAP su dump pcap
  - sparkle-route-adder     : GUI per generazione comandi di routing
  - sparkle-netnumber-links : Analisi ed export link NetNumber SS7/Diameter
  - Sfondo aziendale        : /usr/share/backgrounds/sparkle/background.jpg
  - Profilo VPN             : /etc/iked/sites/tisparkle.vpn

# =========================================================================
# %prep — estrai il tarball nella BUILD dir
# =========================================================================
%prep
%autosetup

# =========================================================================
# %build — nessuna compilazione (Python puro)
# =========================================================================
%build
# nothing to do

# =========================================================================
# %install — popola il buildroot
# =========================================================================
%install
# --- Binari in /usr/bin/ ---------------------------------------------------
install -d %{buildroot}%{_bindir}

for script in \
    sparkle-am-ssh \
    sparkle-loop-checker \
    sparkle-route-adder \
    sparkle-netnumber-links; do
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

# --- Profilo VPN Shrew Soft ------------------------------------------------
install -d %{buildroot}/etc/iked/sites
install -m 0640 assets/tisparkle.vpn \
  %{buildroot}/etc/iked/sites/tisparkle.vpn

# =========================================================================
# %files — lista file inclusi nel pacchetto
# =========================================================================
%files
%license
%doc

%{_bindir}/sparkle-am-ssh
%{_bindir}/sparkle-loop-checker
%{_bindir}/sparkle-route-adder
%{_bindir}/sparkle-netnumber-links

%{_datadir}/sparkle-os/

%{_datadir}/backgrounds/sparkle/background.jpg

%config(noreplace) /etc/iked/sites/tisparkle.vpn

# =========================================================================
# %changelog
# =========================================================================
%changelog
* Sat Mar 01 2026 bl4ckk <bl4ckk@tisparkle.com> - 1.0.0-1
- Prima release ufficiale SparkleOS (Fedora 42 / KDE)
- Integrati: am-ssh, loop-checker, route-adder, netnumber-links
- Aggiunto profilo VPN Shrew Soft (tisparkle.vpn)
- Aggiunto sfondo aziendale
