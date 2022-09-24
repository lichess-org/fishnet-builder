#!/bin/sh -e
_args="$@"
mount -t proc none /debian/proc
mount --bind "$PWD" "/debian/$PWD"
printf -v _command "cd %s; /debian/opt/sde-external-9.0.0-2021-11-07-lin/sde64 %s" "$PWD" "$_args"
chroot /debian sh -c "$_command"
