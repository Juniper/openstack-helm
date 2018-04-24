#!/bin/bash
set -x

OPENCONTRAIL_OVERRIDES="$(echo ./tools/overrides/backends/opencontrail/*)"

for OVERRIDE_FILE in ${OPENCONTRAIL_OVERRIDES} ; do
  if [ -e ${OVERRIDE_FILE} ]; then
    for IMAGE in $(cat ${OVERRIDE_FILE} | yq '.images.tags | map(.) | join(" ")' | tr -d '"'); do
      sudo docker inspect $IMAGE >/dev/null|| sudo docker pull $IMAGE
    done
  fi
done
