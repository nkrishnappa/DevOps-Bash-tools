#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  args: "Upbeat & Sexual Pop"
#  args: 64OO67Be8wOXn6STqHxexr
#
#  Author: Hari Sekhon
#  Date: 2020-06-24 01:17:21 +0100 (Wed, 24 Jun 2020)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

# https://developer.spotify.com/documentation/web-api/reference/playlists/get-playlist/

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090,SC2154
. "$srcdir/lib/spotify.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Returns track names in a given Spotify playlist

Playlist argument can be a playlist name (partial string match) or a playlist ID (get this from spotify_playlists.sh)

\$SPOTIFY_PLAYLIST can be used from environment if no first argument is given


Output format:

Artist - Track

or if \$SPOTIFY_CSV environment variable is set then:

\"Artist\",\"Track\"


$usage_playlist_help

$usage_auth_help
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<playlist_id> [<curl_options>]"

help_usage "$@"

playlist_id="${1:-${SPOTIFY_PLAYLIST:-}}"

shift || :

if is_blank "$playlist_id"; then
    usage "playlist id not defined"
fi

spotify_token

playlist_id="$("$srcdir/spotify_playlist_name_to_id.sh" "$playlist_id" "$@")"

# defined in lib/spotify.sh
# shellcheck disable=SC2154
url_path="/v1/playlists/$playlist_id/tracks?limit=100&offset=$offset"

output(){
    if not_blank "${SPOTIFY_CSV:-}"; then
        jq -r '.items[].track | select(.artists) | [([.artists[].name] | join(", ")), .name] | @csv'
    else
        jq -r '.items[].track | select(.artists) | [([.artists[].name] | join(", ")), "-", .name] | @tsv'
    fi <<< "$output" |
    tr '\t' ' ' |
    sed '
        s/^[[:space:]]*-//;
        s/^[[:space:]]*//;
        s/[[:space:]]*$//
    '
}

while not_null "$url_path"; do
    output="$("$srcdir/spotify_api.sh" "$url_path" "$@")"
    die_if_error_field "$output"
    url_path="$(get_next "$output")"
    output
done
