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

sudo apt-get update
sudo apt-get install --no-install-recommends -y \
        ca-certificates \
        git \
        make \
        jq \
        nmap \
        curl \
        uuid-runtime \
        linux-headers-$(uname -r) \
        ipcalc \
        ntp ntpdate

sudo systemctl stop ntp
sudo bash -c "printf 'tinker panic 0\ndisable monitor\nrestrict default kod nomodify notrap nopeer noquery\nrestrict -6 default kod nomodify notrap nopeer noquery\nrestrict 127.0.0.1\nrestrict -6 ::1\nserver 192.168.1.1 iburst\ndriftfile /var/lib/ntp/drift\n' >> /etc/ntp.conf"
sudo ntpdate 192.168.1.1 || /bin/true
sudo systemctl start ntp
sleep 10
sudo ntpq -p
