#!/bin/bash -eu

function setup_ssh {
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
cat > $HOME/.ssh/id_ed25519<<EOT
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACC3hTqNqke6hZdAaHTCbAmxc/RpyXKoFPd9jFYJjiETiAAAAKhzchaAc3IW
gAAAAAtzc2gtZWQyNTUxOQAAACC3hTqNqke6hZdAaHTCbAmxc/RpyXKoFPd9jFYJjiETiA
AAAEBaGcHdX50W8wsje2VKeaPEXJvwqXWKW3CQgwgGsZuGZLeFOo2qR7qFl0BodMJsCbFz
9GnJcqgU932MVgmOIROIAAAAJXZhZ3JhbnRAbWFzdGVyLjE5Mi4xNjguMjUzLjEwMC5uaX
AuaW8=
-----END OPENSSH PRIVATE KEY-----
EOT
chmod 700 $HOME/.ssh/id_ed25519
}

function setup_ansible {
export PATH_ORIGIN=`pwd`
if [! -f openshift-ansible ]; then
git clone https://github.com/openshift/openshift-ansible.git
fi
cd openshift-ansible && git fetch && git checkout release-3.11

cat >hosts.ini <<EOT
# Create an OSEv3 group that contains the masters, nodes, and etcd groups
[OSEv3:children]
masters
nodes
etcd

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
# SSH user, this user should allow ssh based auth without requiring a password
ansible_ssh_user=root
# If ansible_ssh_user is not root, ansible_become must be set to true
ansible_become=true
openshift_master_default_subdomain=master.192.168.253.100.nip.io
deployment_type=origin

[nodes:vars]
openshift_disable_check=disk_availability,memory_availability,docker_storage
[masters:vars]
openshift_disable_check=disk_availability,memory_availability,docker_storage
# uncomment the following to enable htpasswd authentication; defaults to DenyAllPasswordIdentityProvider
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]

# host group for masters
[masters]
192.168.253.100

# host group for etcd
[etcd]
192.168.253.100

# host group for nodes, includes region info
[nodes]
192.168.253.100  openshift_node_group_name='node-config-master'
192.168.253.101  openshift_node_group_name='node-config-compute'
192.168.253.102  openshift_node_group_name='node-config-compute'
192.168.253.100  openshift_node_group_name='node-config-infra'
EOT

ansible-playbook -i hosts.ini playbooks/prerequisites.yml
ansible-playbook -i hosts.ini playbooks/deploy_cluster.yml

cd $PATH_ORIGIN
}

setup_ssh
setup_ansible