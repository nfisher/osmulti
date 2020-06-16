#!/bin/bash -eu

KUBELET_IP=$1; export KUBELET_IP

source /vagrant/versions.rc

function install_packages {
yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

yum install -y \
    docker-${DOCKER_VERSION} \
    git \
    centos-release-ansible-27 \
    ;
# centos-release-ansible-27 only adds repo.
yum install -y ansible
}

function setup_docker {
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
     "insecure-registries" : [ "172.30.0.0/16" ]
}
EOF


systemctl daemon-reload
systemctl restart docker
}

function setup_sysctl {
# networking config
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables=1
net.bridge.bridge-nf-call-iptables=1
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
EOF

sysctl --system
}

function setup_ssh {
mkdir -p /root/.ssh
chmod 700 /root/.ssh
touch /root/.ssh/authorized_keys
chmod 700 /root/.ssh/authorized_keys
grep 'vagrant@master.192.168.253.100.nip.io' /root/.ssh/authorized_keys \
    || echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILeFOo2qR7qFl0BodMJsCbFz9GnJcqgU932MVgmOIROI vagrant@master.192.168.253.100.nip.io' >> /root/.ssh/authorized_keys
}

install_packages
setup_sysctl
setup_ssh