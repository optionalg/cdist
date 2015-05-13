#!/bin/sh

# Generate filelist excluding stuff that takes only space
for pkg in bash systemd util-linux openssh; do
    pacman -Qlq $pkg | grep -v \
        -e /usr/share/man/
done
