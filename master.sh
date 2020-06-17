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

mkdir -p /etc/origin/master/
touch /etc/origin/master/htpasswd

if [ ! -d openshift-ansible ]; then
git clone https://github.com/openshift/openshift-ansible.git
fi
cd openshift-ansible && git fetch && git checkout release-3.11

cat >hosts.ini <<EOT
# https://github.com/okd-community-install/installcentos/blob/master/inventory.ini
# Create an OSEv3 group that contains the masters, nodes, and etcd groups
[OSEv3:children]
masters
nodes
etcd

# Set variables common for all OSEv3 hosts
[OSEv3:vars]
openshift_additional_repos=[{'id': 'centos-paas', 'name': 'centos-paas', 'baseurl' :'https://buildlogs.centos.org/centos/7/paas/x86_64/openshift-origin311', 'gpgcheck' :'0', 'enabled' :'1'}]

ansible_ssh_user=root
ansible_become=true
enable_excluders=False
enable_docker_excluder=False
ansible_service_broker_install=False

containerized=True
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
openshift_disable_check=disk_availability,docker_storage,memory_availability,docker_image_availability

deployment_type=origin
openshift_deployment_type=origin

template_service_broker_selector={"region":"infra"}
#openshift_web_console_nodeselector={'region':'infra'}

openshift_metrics_install_metrics=False
openshift_logging_install_logging=False

openshift_logging_elasticsearch_proxy_image_version="v1.0.0"
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra":"true"}
logging_elasticsearch_rollout_override=false
osm_use_cockpit=True

openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_htpasswd_file='/etc/origin/master/htpasswd'

openshift_master_default_subdomain=master.192.168.253.100.nip.io
openshift_public_hostname=master.192.168.253.100.nip.io

etcd_ip=192.168.253.100

# host group for masters
[masters]
192.168.253.100 openshift_ip=192.168.253.100

# host group for etcd
[etcd]
192.168.253.100 openshift_ip=192.168.253.100

# host group for nodes, includes region info
[nodes]
192.168.253.100  openshift_node_group_name='node-config-master'
192.168.253.101  openshift_node_group_name='node-config-compute'
192.168.253.102  openshift_node_group_name='node-config-compute'
192.168.253.103  openshift_node_group_name='node-config-infra'
EOT

ansible-playbook -i hosts.ini playbooks/prerequisites.yml
ansible-playbook -i hosts.ini playbooks/deploy_cluster.yml

cd $PATH_ORIGIN
}

setup_ssh
setup_ansible