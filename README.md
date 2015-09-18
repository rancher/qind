# QIND - QEMU in Docker

Docker image: rancher/qind

An easy to use QEMU runner. Its current primary purpose is to help test RancherOS, but feel free to use otherwise. 

Usage:

```sh
$ docker run  -d --name=qind-vm -it --device=/dev/kvm:/dev/kvm -p 2222:22 \
              -v ./stuff:/stuff \
              rancher/qind \
              --hostname "your-host" \
              --hd /stuff/hd.img \
              --ssh-pub /stuff/id_rsa.pub \
              --cloud-config /stuff/cloud-config.yml \
              -m 1G -kernel /stuff/vmlinuz -initrd /stuff/initrd -append "console=ttyS0 kernel.params=here"
```

This spins up a VM with your kernel and initrd, sets kernel boot params, and lets you provide hostname, persistent disk image, a cloud-config file or an SSH public key. All of those are optional. Arbitrary QEMU options go last in the command line. 

You can SSH into the VM on port 2222. 

Use `--device=/dev/kvm:/dev/kvm` if your docker host has KVM - your VM will thank you :)
