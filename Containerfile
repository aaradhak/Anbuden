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
    tmux \
    # run local qemu vms
    libvirt-daemon-config-network libvirt-daemon-kvm qemu-kvm \
    virt-install virt-manager virt-viewer 

# Add aliases and functions to ~/.bashrc
RUN echo 'alias butane="podman run --rm --tty --interactive \\' >> ~/.bashrc && \
    echo '              --security-opt label=disable        \\' >> ~/.bashrc && \
    echo '              --volume ${PWD}:/pwd --workdir /pwd \\' >> ~/.bashrc && \
    echo '              quay.io/coreos/butane:release"' >> ~/.bashrc && \
    echo '' >> ~/.bashrc && \
    echo 'alias coreos-installer="podman run --pull=always            \\' >> ~/.bashrc && \
    echo '                        --rm --interactive                  \\' >> ~/.bashrc && \
    echo '                        --security-opt label=disable        \\' >> ~/.bashrc && \
    echo '                        --volume ${PWD}:/pwd --workdir /pwd \\' >> ~/.bashrc && \
    echo '                        quay.io/coreos/coreos-installer:release"' >> ~/.bashrc && \
    echo '' >> ~/.bashrc && \
    echo 'alias ignition-validate="podman run --rm --tty --interactive \\' >> ~/.bashrc && \
    echo '                         --security-opt label=disable        \\' >> ~/.bashrc && \
    echo '                         --volume ${PWD}:/pwd --workdir /pwd \\' >> ~/.bashrc && \
    echo '                         quay.io/coreos/ignition-validate:release"' >> ~/.bashrc && \
    echo '' >> ~/.bashrc && \
    echo 'cosa() {' >> ~/.bashrc && \
    echo '   env | grep COREOS_ASSEMBLER' >> ~/.bashrc && \
    echo '   local -r COREOS_ASSEMBLER_CONTAINER_LATEST="quay.io/coreos-assembler/coreos-assembler:latest"' >> ~/.bashrc && \
    echo '   if [[ -z ${COREOS_ASSEMBLER_CONTAINER} ]] && $(podman image exists ${COREOS_ASSEMBLER_CONTAINER_LATEST}); then' >> ~/.bashrc && \
    echo '       local -r cosa_build_date_str="$(podman inspect -f "{{.Created}}" ${COREOS_ASSEMBLER_CONTAINER_LATEST} | awk \'{print $1}\')"' >> ~/.bashrc && \
    echo '       local -r cosa_build_date="$(date -d ${cosa_build_date_str} +%s)"' >> ~/.bashrc && \
    echo '       if [[ $(date +%s) -ge $((cosa_build_date + 60*60*24*7)) ]] ; then' >> ~/.bashrc && \
    echo '         echo -e "\e[0;33m----" >&2' >> ~/.bashrc && \
    echo '         echo "The COSA container image is more that a week old and likely outdated." >&2' >> ~/.bashrc && \
    echo '         echo "You should pull the latest version with:" >&2' >> ~/.bashrc && \
    echo '         echo "podman pull ${COREOS_ASSEMBLER_CONTAINER_LATEST}" >&2' >> ~/.bashrc && \
    echo '         echo -e "----\e[0m" >&2' >> ~/.bashrc && \
    echo '         sleep 10' >> ~/.bashrc && \
    echo '       fi' >> ~/.bashrc && \
    echo '   fi' >> ~/.bashrc && \
    echo '   set -x' >> ~/.bashrc && \
    echo '   podman run --rm -ti --security-opt label=disable --privileged                                    \\' >> ~/.bashrc && \
    echo '              --uidmap=1000:0:1 --uidmap=0:1:1000 --uidmap 1001:1001:64536                          \\' >> ~/.bashrc && \
    echo '              -v ${PWD}:/srv/ --device /dev/kvm --device /dev/fuse                                  \\' >> ~/.bashrc && \
    echo '              --tmpfs /tmp -v /var/tmp:/var/tmp --name cosa                                         \\' >> ~/.bashrc && \
    echo '              ${COREOS_ASSEMBLER_CONFIG_GIT:+-v $COREOS_ASSEMBLER_CONFIG_GIT:/srv/src/config/:ro}   \\' >> ~/.bashrc && \
    echo '              ${COREOS_ASSEMBLER_GIT:+-v $COREOS_ASSEMBLER_GIT/src/:/usr/lib/coreos-assembler/:ro}  \\' >> ~/.bashrc && \
    echo '              ${COREOS_ASSEMBLER_ADD_CERTS:+-v=/etc/pki/ca-trust:/etc/pki/ca-trust:ro}              \\' >> ~/.bashrc && \
    echo '              ${COREOS_ASSEMBLER_CONTAINER_RUNTIME_ARGS}                                            \\' >> ~/.bashrc && \
    echo '              ${COREOS_ASSEMBLER_CONTAINER:-$COREOS_ASSEMBLER_CONTAINER_LATEST} "$@"' >> ~/.bashrc && \
    echo '   rc=$?; set +x; return $rc' >> ~/.bashrc && \
    echo '}' >> ~/.bashrc
