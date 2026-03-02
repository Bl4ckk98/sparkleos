# ============================================================
# SparkleOS - Repository Configuration
# ============================================================
# Usa $releasever (impostato da --releasever in livemedia-creator)
# per evitare di hardcodare la versione Fedora.
# Allineato allo standard Fedora (fedora-repo-not-rawhide.ks).
# ============================================================

repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch

# SparkleOS Copr repository
repo --name=copr-sparkle-os --baseurl=https://download.copr.fedorainfracloud.org/results/bl4ckk/sparkle-os/fedora-$releasever-x86_64/
