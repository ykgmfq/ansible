set -eu \
&& fedora=$(rpm -E %fedora) \
&& url="https://copr.fedorainfracloud.org/coprs/leo3418/jellyfin/repo/fedora-$fedora/leo3418-jellyfin-fedora-$fedora.repo" \
&& curl --no-progress-meter --remote-name --output-dir /etc/yum.repos.d $url \
&& dnf -y install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora.noarch.rpm \
&& dnf -y install --setopt=install_weak_deps=0 jellyfin \
&& dnf clean all
