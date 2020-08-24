#!/bin/sh
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-08-23 23:30:31 +0100 (Sun, 23 Aug 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

#  Used on Alpine so needs to be /bin/sh

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x

# used in client code
# shellcheck disable=SC2034
package_args_description="Takes a list of packages as arguments or via stdin, and for any arguments that are plaintext files, reads the packages from those given files (one package per line)"

packages=""

_process_package_args(){
    for arg; do
        if [ -f "$arg" ] && file "$arg" | grep -q ASCII; then
            echo "adding packages from file:  $arg" >&2
            packages="$packages $(sed 's/#.*//;/^[[:space:]]*$$/d' "$arg")"
            echo >&2
        else
            packages="$packages $arg"
        fi
    done
    # Homebrew tap package lists are in format "tap package" and those lines should not be split
    echo "$packages" |
    if [ -n "${HOMEBREW_PACKAGES_TAP:-}" ]; then
        cat
    else
        tr ' ' '\n' |
        sort -u
    fi |
    grep -v '^[[:space:]]*$'
}

process_package_args(){
    if [ -n "${*:-}" ]; then
        _process_package_args "$@"
    else
        # shellcheck disable=SC2046
        _process_package_args $(cat)
    fi
}

installed_apk(){
    apk info 2>/dev/null
}

installed_debs(){
    dpkg-query -W -f '${db:Status-Abbrev}\t${binary:Package}\n' |
    awk '/^i/{print $2}' |
    sed 's/:.*$//' |
    sort -u
}

installed_rpms(){
    rpm -qa --queryformat '%{RPMTAG_NAME}\n'
}

rpms_filter_provided(){
    while read -r rpm; do
        # accounts for vim being provided by vim-enhanced, so we don't try to install the metapackage again and again
        rpm -q --whatprovides "$rpm" >/dev/null 2>&1 &&
        echo "$rpm"
    done
}

rpms_filter_not_provided(){
    while read -r rpm; do
        # accounts for vim being provided by vim-enhanced, so we don't try to install the metapackage again and again
        rpm -q --whatprovides "$rpm" >/dev/null 2>&1 ||
        echo "$rpm"
    done
}