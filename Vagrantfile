# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider "vmware" do |vb|
    # Customize the number of cpus on the VM:
    vb.cpus = "2"

    # Customize the amount of memory on the VM:
    vb.memory = "4096"
  end

  required_plugins = %w( vagrant-vbguest )
  required_plugins.each do |plugin|
    system "vagrant plugin install #{plugin}" unless Vagrant.has_plugin? plugin
  end

  # Choose operating system distribution
  config.vm.box = "generic/alpine317"

  # Share the working folder
  config.vm.synced_folder "./", "/vagrant/project"

  config.vm.provision "shell", inline: <<-SHELL
    # Matching linux installation instructions
    echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    apk add libattr apptainer@testing
  SHELL
end