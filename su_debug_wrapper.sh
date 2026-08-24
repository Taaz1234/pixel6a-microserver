#!/bin/bash
echo "SU called with args: $@" >> /tmp/su_debug.log

# Extract the -c argument
cmd=""
while [ $# -gt 0 ]; do
    if [ "$1" = "-c" ] || [ "$1" = "--command" ]; then
        shift
        cmd="$1"
        break
    fi
    shift
done

echo "Extracted CMD: $cmd" >> /tmp/su_debug.log

if [ -n "$cmd" ]; then
    export HOME=/root
    export TMPDIR=/tmp
    export TEMP=/tmp
    export TMP=/tmp
    export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/cubecoders/amp
    /bin/bash -c "$cmd"
    ret=$?
    echo "CMD Exit code: $ret" >> /tmp/su_debug.log
    exit $ret
else
    exit 0
fi
