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

#NOTE: Deploy command
helm upgrade --install mistral ./mistral \
  --namespace=openstack $values \
  --set pod.replicas.api=2 \
  --set pod.replicas.engine=2 \
  --set pod.replicas.event_engine=2 \
  --set pod.replicas.executor=2

#NOTE: Wait for deploy
./tools/deployment/common/wait-for-pods.sh openstack

#NOTE: Validate Deployment info
export OS_CLOUD=openstack_helm
openstack service list
