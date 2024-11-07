FROM quay.io/fedora/fedora-coreos:testing
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
