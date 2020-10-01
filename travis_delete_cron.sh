#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-09-30 20:47:00 +0100 (Wed, 30 Sep 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Deletes a given Travis CI cron by ID

See travis_repo_crons.sh which outputs the IDs are the first field

Prints the JSON of the cron it deleted

Uses the adjacent travis_api.sh script
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<cron_id>"

help_usage "$@"

min_args 1 "$@"

cron_id="$1"

url_path="/cron/$cron_id"

timestamp "deleting Travis CI cron job '$cron_id'" >&2
"$srcdir/travis_api.sh" "$url_path" -X DELETE