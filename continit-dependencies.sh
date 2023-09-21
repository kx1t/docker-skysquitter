#!/bin/bash

if [[ -z "$1" ]]; then
    echo "Need to invoke with the rootfs directory as command line argument"
    exit 1
fi
if [[ ! -d "$1" ]]; then
    echo "$1 (rootfs directory) doesn't exist."
    exit 1
fi

rootdir="$1"
#shellcheck disable=SC2207,SC2011
list=($(ls "$rootdir/back/cont-init.d/"|xargs))

for name in "${list[@]:1}"; do
    echo -n "dir $name dependencies: "
    for dependency in "${list[@]}"; do
        if [[ "$dependency" == "$name" ]]; then break; fi
        echo -n "$dependency "
        mkdir -p "$rootdir/etc/s6-overlay/s6-rc.d/$name/dependencies.d"
        touch "$rootdir/etc/s6-overlay/s6-rc.d/$name/dependencies.d/$dependency"
        rm -f "$rootdir/etc/s6-overlay/s6-rc.d/$name/dependencies.d/dependency"
    done
    echo ""
done
