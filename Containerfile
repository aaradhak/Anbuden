FROM quay.io/fedora/fedora-coreos:next

# First install bootc and dnf until it's included...
RUN dnf -y install \
    # local debug tools 
    htop ripgrep  \
    # kerberos auth
    krb5-workstation \
    # dev tools
    make xsel strace \
    # TMUX TOOL
    tmux 
    # run local qemu vms
    #libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm \
    #virt-install virt-manager virt-viewer 

