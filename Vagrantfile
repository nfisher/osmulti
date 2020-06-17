# -*- mode: ruby -*-
# vi: set ft=ruby :


Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"


  #
  # node01 configuration
  #
  config.vm.define "node01" do |node|
    resources(node, 2, 4096)

    node.vm.network "private_network", ip: "192.168.253.101"
    node.vm.hostname = "node01"

    node.vm.provision :shell, inline: "hostnamectl set-hostname node01.192.168.253.101.nip.io"
    node.vm.provision "shell", path: "provision.sh", args: ["192.168.253.101"]
  end

  #
  # node02 configuration
  #
  config.vm.define "node02" do |node|
    resources(node, 2, 4096)

    node.vm.network "private_network", ip: "192.168.253.102"
    node.vm.hostname = "node02"

    node.vm.provision :shell, inline: "hostnamectl set-hostname node02.192.168.253.102.nip.io"
    node.vm.provision "shell", path: "provision.sh", args: ["192.168.253.102"]
  end

  #
  # infra01 configuration
  #
  config.vm.define "infra01" do |node|
    resources(node, 2, 4096)

    node.vm.network "private_network", ip: "192.168.253.103"
    node.vm.hostname = "infra01"

    node.vm.provision :shell, inline: "hostnamectl set-hostname infra01.192.168.253.103.nip.io"
    node.vm.provision "shell", path: "provision.sh", args: ["192.168.253.103"]
  end

  #
  # master configuration, must be provisioned after nodes.
  #
  config.vm.define "master" do |node|
    resources(node, 2, 8192)

    node.vm.network "private_network", ip: "192.168.253.100"
    node.vm.hostname = "master"

    node.vm.provision :shell, inline: "hostnamectl set-hostname master.192.168.253.100.nip.io"
    node.vm.provision "shell", path: "provision.sh", args: ["192.168.253.100"]
    node.vm.provision "shell", path: "master.sh", args: ["192.168.253.100"]
  end
end

def resources(node, cpu, memory)
    node.vm.provider "virtualbox" do |vb|
      vb.cpus = cpu.to_i
      vb.memory = memory.to_s
    end

    node.vm.provider "vmware_desktop" do |v|
      v.vmx["numvcpus"] = cpu.to_s
      v.vmx["memsize"] = memory.to_s
    end
end