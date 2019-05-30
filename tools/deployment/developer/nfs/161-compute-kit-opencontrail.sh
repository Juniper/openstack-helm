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

#NOTE: Pull images and lint chart
make pull-images nova
make pull-images neutron

#NOTE: Pull opencontrail images from override files
./tools/pull-opencontrail-images.sh

#NOTE: Deploy nova
OPENSTACK_VERSION=${OPENSTACK_VERSION:-"ocata"}
if [ "$OPENSTACK_VERSION" == "ocata" ]; then
  values="--values=./tools/overrides/releases/ocata/loci.yaml "

  # Insert $values to OSH_EXTRA_HELM_ARGS_NEUTRON
  OSH_EXTRA_HELM_ARGS_NEUTRON="$values "$OSH_EXTRA_HELM_ARGS_NEUTRON

  # Add nova ocata override files
  values+="--values=./tools/overrides/backends/opencontrail/nova-ocata.yaml "

  # Insert $values to OSH_EXTRA_HELM_ARGS_NOVA
  OSH_EXTRA_HELM_ARGS_NOVA="$values "$OSH_EXTRA_HELM_ARGS_NOVA
fi

if [ "x$(systemd-detect-virt)" == "xnone" ]; then
  echo 'OSH is not being deployed in virtualized environment'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=./tools/overrides/backends/opencontrail/nova.yaml \
      --set ceph.enabled=false \
      ${OSH_EXTRA_HELM_ARGS} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
else
  echo 'OSH is being deployed in virtualized environment, using qemu for nova'
  helm upgrade --install nova ./nova \
      --namespace=openstack \
      --values=./tools/overrides/backends/opencontrail/nova.yaml \
      --set ceph.enabled=false \
      --set conf.nova.libvirt.virt_type=qemu \
      ${OSH_EXTRA_HELM_ARGS} \
      ${OSH_EXTRA_HELM_ARGS_NOVA}
fi

#NOTE: Deploy neutron
helm upgrade --install neutron ./neutron \
    --namespace=openstack \
    --values=./tools/overrides/backends/opencontrail/neutron.yaml \
    --set conf.openstack_version=$OPENSTACK_VERSION \
    ${OSH_EXTRA_HELM_ARGS} \
    ${OSH_EXTRA_HELM_ARGS_NEUTRON}

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
sleep 30 #NOTE(portdirect): Wait for ingress controller to update rules and restart Nginx
openstack hypervisor list
openstack network agent list
