#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2020-08-13 19:38:39 +0100 (Thu, 13 Aug 2020)
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
Lists GCP storage resources deployed in the current GCP Project

Lists in this order:

    - Cloud SQL instances
    - Cloud Storage Buckets
    - Cloud Filestore
    - Cloud Memorystore Redis
    - BigTable clusters and instances
    - Datastore Indexes
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args=""

help_usage "$@"


# shellcheck disable=SC1090
type is_service_enabled &>/dev/null || . "$srcdir/gcp_service_apis.sh" >/dev/null


# Cloud SQL instances
cat <<EOF
# ============================================================================ #
#                     C l o u d   S Q L   I n s t a n c e s
# ============================================================================ #

EOF

# might need this one instead sqladmin.googleapis.com
if is_service_enabled sql-component.googleapis.com; then
    gcloud sql instances list
else
    echo "Cloud SQL API (sql-component.googleapis.com) is not enabled, skipping..."
fi


# Cloud Storage Buckets
cat <<EOF


# ============================================================================ #
#                                 B u c k e t s
# ============================================================================ #

EOF

if is_service_enabled storage-component.googleapis.com; then
    gsutil ls
else
    echo "Cloud Storage API (storage-component.googleapis.com) is not enabled, skipping..."
fi


# Cloud Filestore
cat <<EOF


# ============================================================================ #
#                         C l o u d   F i l e s t o r e
# ============================================================================ #

EOF

if is_service_enabled file.googleapis.com; then
    gcloud filestore instances list
else
    echo "Cloud Filestore API (file.googleapis.com) is not enabled, skipping..."
fi


# Cloud MemoryStore Redis
cat <<EOF


# ============================================================================ #
#                 C l o u d   M e m o r y s t o r e   R e d i s
# ============================================================================ #

EOF

if is_service_enabled redis.googleapis.com; then
    gcloud redis instances list --region all
else
    echo "Cloud Memorystore Redis API (redis.googleapis.com) is not enabled, skipping..."
fi


# BigTable clusters and instances
cat <<EOF


# ============================================================================ #
#                                B i g T a b l e
# ============================================================================ #

EOF

# works even with these disabled:
#
# DISABLED  bigtable.googleapis.com                               Cloud Bigtable API
# DISABLED  bigtableadmin.googleapis.com                          Cloud Bigtable Admin API
# DISABLED  bigtabletableadmin.googleapis.com                     Cloud Bigtable Table Admin API
#
# if is_service_enabled bigtable.googleapis.com; then
    echo "Clusters:"
    gcloud bigtable clusters list
    echo
    echo "Instances:"
    gcloud bigtable instances list
#else
#    echo "BigTable API (bigtable.googleapis.com) is not enabled, skipping..."
#fi


# Datastore Indexes
cat <<EOF


# ============================================================================ #
#                       D a t a s t o r e   I n d e x e s
# ============================================================================ #

EOF

if is_service_enabled datastore.googleapis.com; then
    gcloud datastore indexes list
else
    echo "Datastore API datastore.googleapis.com) is not enabled, skipping..."
fi