#!/bin/bash

# Copyright 2017 The Openstack-Helm Authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
set -xe

OPENSTACK_VERSION=${OPENSTACK_VERSION:-"ocata"}
if [ "$OPENSTACK_VERSION" == "ocata" ]; then
  values="--values=./tools/overrides/releases/ocata/loci.yaml "
else
  values=""
fi

HUGE_PAGES_DIR=${HUGE_PAGES_DIR:-""}
if [[ ! -z "$HUGE_PAGES_DIR" ]]; then
tee /tmp/libvirt_mount.yaml << EOF
pod:
  mounts:
    libvirt:
      libvirt:
        volumeMounts:
          - name: hugepages-dir
            mountPath: $HUGE_PAGES_DIR
        volumes:
          - name: hugepages-dir
            hostPath:
              path: $HUGE_PAGES_DIR
EOF
fi


#NOTE: Deploy command
if [[ -z "$HUGE_PAGES_DIR" ]]; then
  echo "Libvirt is being deployed"
  helm upgrade --install libvirt ./libvirt \
    --namespace=openstack $values \
    --values=./tools/overrides/backends/opencontrail/libvirt.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_LIBVIRT}
else
  echo "Libvirt is being deployed, with hugepages mount directory"
  helm upgrade --install libvirt ./libvirt \
    --namespace=openstack $values \
    --values=./tools/overrides/backends/opencontrail/libvirt.yaml \
    --values=/tmp/libvirt_mount.yaml \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_LIBVIRT}
fi

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
helm status libvirt
