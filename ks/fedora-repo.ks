# ============================================================
# SparkleOS - Repository Configuration (Fedora 42)
# ============================================================

url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-42&arch=$basearch

repo --name=fedora-updates \
     --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f42&arch=$basearch

# Copr SparkleOS - pacchetto aziendale
# NOTA: La GPG key è inclusa nel pacchetto copr-sparkle-os-release
repo --name=copr-sparkle-os \
     --baseurl=https://download.copr.fedorainfracloud.org/results/bl4ckk/sparkle-os/fedora-42-x86_64/
