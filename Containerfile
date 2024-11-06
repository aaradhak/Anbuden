FROM quay.io/fedora/fedora-coreos:testing
# First install bootc and dnf until it's included...
RUN dnf -y install \
    # sign git tags for releases
    git-evtag pinentry \
    # local debug tools 
    htop ripgrep  \
    # kerberos auth
    krb5-workstation \
    # run local qemu vms
    libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm \
    virt-install virt-manager virt-viewer \
    # podman machine and reqs
    podman-gvproxy virtiofsd \
    # dev tools
    make xsel strace \
    # preffered tools
    tmux 
