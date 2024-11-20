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

# Add aliases and functions to ~/.bashrc using a HERE document
RUN cat << 'EOF' >> ~/.bashrc
alias butane='podman run --rm --tty --interactive \
              --security-opt label=disable        \
              --volume ${PWD}:/pwd --workdir /pwd \
              quay.io/coreos/butane:release'

alias coreos-installer='podman run --pull=always            \
                        --rm --interactive                  \
                        --security-opt label=disable        \
                        --volume ${PWD}:/pwd --workdir /pwd \
                        quay.io/coreos/coreos-installer:release'

alias ignition-validate='podman run --rm --tty --interactive \
                         --security-opt label=disable        \
                         --volume ${PWD}:/pwd --workdir /pwd \
                         quay.io/coreos/ignition-validate:release'

cosac() {
   env | grep COREOS_ASSEMBLER
   local -r COREOS_ASSEMBLER_CONTAINER_LATEST="quay.io/coreos-assembler/coreos-assembler:latest"
   if [[ -z ${COREOS_ASSEMBLER_CONTAINER} ]] && $(podman image exists ${COREOS_ASSEMBLER_CONTAINER_LATEST}); then
       local -r cosa_build_date_str="$(podman inspect -f "{{.Created}}" ${COREOS_ASSEMBLER_CONTAINER_LATEST} | awk '{print $1}')"
       local -r cosa_build_date="$(date -d ${cosa_build_date_str} +%s)"
       if [[ $(date +%s) -ge $((cosa_build_date + 60*60*24*7)) ]] ; then
         echo -e "\e[0;33m----" >&2
         echo "The COSA container image is more that a week old and likely outdated." >&2
         echo "You should pull the latest version with:" >&2
         echo "podman pull ${COREOS_ASSEMBLER_CONTAINER_LATEST}" >&2
         echo -e "----\e[0m" >&2
         sleep 10
       fi
   fi
   set -x
   podman run --rm -ti --security-opt label=disable --privileged                                    \
              --uidmap=1000:0:1 --uidmap=0:1:1000 --uidmap 1001:1001:64536                          \
              -v ${PWD}:/srv/ --device /dev/kvm --device /dev/fuse                                  \
              --tmpfs /tmp -v /var/tmp:/var/tmp --name cosa                                         \
              ${COREOS_ASSEMBLER_CONFIG_GIT:+-v $COREOS_ASSEMBLER_CONFIG_GIT:/srv/src/config/:ro}   \
              ${COREOS_ASSEMBLER_GIT:+-v $COREOS_ASSEMBLER_GIT/src/:/usr/lib/coreos-assembler/:ro}  \
              ${COREOS_ASSEMBLER_ADD_CERTS:+-v=/etc/pki/ca-trust:/etc/pki/ca-trust:ro}              \
              ${COREOS_ASSEMBLER_CONTAINER_RUNTIME_ARGS}                                            \
              ${COREOS_ASSEMBLER_CONTAINER:-$COREOS_ASSEMBLER_CONTAINER_LATEST} "$@"
   rc=$?; set +x; return $rc
}
EOF
