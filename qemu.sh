#!/bin/sh
set -e -x

BASE=$(pwd)
BUILD=${BASE}/build

HD=${BASE}/state/hd.img
USER_DATA=${BUILD}/cloud-config/openstack/latest/user_data
mkdir -p $(dirname ${USER_DATA})

while [ "$#" -gt 0 ]; do
    case $1 in
        --hostname)
            shift 1
            HOST_NAME="$1"
            ;;
        --hd)
            shift 1
            HD=$(readlink -f  "$1") || :
            if [ ! -f ${HD} ]; then
                echo No such file: "'"${HD}"'" 1>&2
                exit 1
            fi
            ;;
        --ssh-pub)
            shift 1
            PUB_KEY=$(readlink -f  "$1") || :
            if [ ! -f ${PUB_KEY} ]; then
                echo No such file: "'"${PUB_KEY}"'" 1>&2
                exit 1
            fi
            ;;
        --cloud-config)
            shift 1
            CLOUD_CONFIG=$(readlink -f  "$1") || :
            if [ ! -f ${CLOUD_CONFIG} ]; then
                echo No such file: "'"${CLOUD_CONFIG}"'" 1>&2
                exit 1
            fi
            ;;
        *)
            break
            ;;
    esac
    shift 1
done

if [ ! -e ${HD} ]; then
    mkdir -p $(dirname ${HD})
    qemu-img create -f qcow2 -o size=20G ${HD}
fi

if [ -n "$CLOUD_CONFIG" ]; then
    cat ${CLOUD_CONFIG} > ${USER_DATA}
fi
if [ -n "$PUB_KEY" ]; then
    echo "#cloud-config" >> ${USER_DATA}
    echo "ssh_authorized_keys:" >> ${USER_DATA}
    echo "- $(<${PUB_KEY})" >> ${USER_DATA}
fi

if [ -e "$USER_DATA" ]; then
    CLOUD_CONFIG_ISO="${BUILD}/cloud-config.iso"
    rm -rf ${CLOUD_CONFIG_ISO}
    mkisofs -R -V config-2 -o "${CLOUD_CONFIG_ISO}" "$BUILD/cloud-config"
    CLOUD_CONFIG_ENABLE="-cdrom ${CLOUD_CONFIG_ISO}"
fi

if [ -c /dev/kvm ] && [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
    KVM_ENABLE="-machine accel=kvm -cpu host"
fi

exec qemu-system-x86_64 -serial stdio \
    -net nic,vlan=0,model=virtio \
    -net user,vlan=0,hostfwd=::2222-:22,hostname=${HOST_NAME:-qind} \
    -drive if=virtio,file=${HD} \
    ${KVM_ENABLE} \
    -smp 2 \
    ${CLOUD_CONFIG_ENABLE} \
    -nographic \
    -display none \
    "${@}"

#    -m 1G
#    -kernel <KERNEL>
#    -initrd <INITRD>
#    -append "console=ttyS0 <KERNEL_PARAMS>"
