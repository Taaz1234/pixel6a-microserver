#!/bin/bash

cmd=""
while [ $# -gt 0 ]; do
    if [ "$1" = "-c" ] || [ "$1" = "--command" ]; then
        shift
        cmd="$1"
        break
    fi
    shift
done

if [ -n "$cmd" ]; then
    export HOME=/root
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TMP=/tmp
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
    exec /bin/bash -c "$cmd"
else
    exit 0
fi
