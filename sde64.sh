#!/bin/bash -e
_args="$@"
mount -t proc none /debian/proc
mkdir -p "/debian/$PWD"
mount --bind "$PWD" "/debian/$PWD"
printf -v _command "cd %s; /opt/sde-external-9.0.0-2021-11-07-lin/sde64 %s" "$PWD" "$_args"
chroot /debian sh -c "$_command"
