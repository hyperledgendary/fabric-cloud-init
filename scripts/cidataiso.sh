#!/bin/sh -l

#
# SPDX-License-Identifier: Apache-2.0
#

usage() {
    echo "Usage: cidataiso.sh -u <user-data file>"
    echo
    echo "  Creates a cloud init ISO"
    echo
    echo "    Flags:"
    echo "    -u <user-data file> - the cloud-config user-data file to include in the ISO"
    echo "    -h - Print this message"
}

error_exit() {
    echo "${1:-"Unknown Error"}" 1>&2
    exit 1
}

while getopts "hu:" opt; do
    case "$opt" in
        h)
            usage
            exit 0
            ;;
        u)
            config=${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))

if [ ! -f "$config" ]; then
    usage
    exit 1
fi

isoname=config.iso

prefix=$(basename "$0")
tempdir=$(mktemp -d -t "$prefix.XXXXXXXX") || error_exit "Error creating temporary directory"

if [ -n "$DEBUG" ]; then
    echo "config = $config"
    echo "isoname = $isoname"
    echo "tempdir = $tempdir"
fi

mkdir -p "$tempdir/cidata"
cp "$config" "$tempdir/cidata/user-data"
touch "$tempdir/cidata/meta-data"

if command -v hdiutil > /dev/null; then
    hdiutil makehybrid -o "$isoname" -hfs -joliet -iso -default-volume-name cidata "$tempdir/cidata"
elif command -v genisoimage > /dev/null; then
    genisoimage -output "$isoname" -volid cidata -joliet -rock "$tempdir/cidata/user-data" "$tempdir/cidata/meta-data"
else
    error_exit "Cannot find hdiutil or genisoimage"
fi

rm -Rf "$tempdir"
