# -*- mode: ruby -*-
# vi: set ft=ruby :

domain = 'avi.com'

puppet_nodes = [
  {:hostname => 'puppet',  :ip => '172.16.32.10', :box => 'vStone/centos-7.x-puppet.3.x',
	:fwdhost => 8080, 
	:fwdguest => 80, 
	:fwdhost => 8140, 
	:fwdguest => 8140, 
	:fwdhost => 3000, 
	:fwdguest => 3000, 
	:ram => 4096
  },
  {:hostname => 'client1', :ip => '172.16.32.11', :box => 'vStone/centos-7.x-puppet.3.x'},
  {:hostname => 'client2', :ip => '172.16.32.12', :box => 'vStone/centos-7.x-puppet.3.x'},
  {:hostname => 'kibana', :ip => '172.16.32.13', :box => 'vStone/centos-7.x-puppet.3.x',
	:fwdhost => 5601, 
	:fwdguest => 80, 
  },
]

Vagrant.configure("2") do |config|
  puppet_nodes.each do |node|
    config.vm.define node[:hostname] do |node_config|
      node_config.vm.box = node[:box]
      #https://atlas.hashicorp.com/vStone/centos-7.x-puppet.3.x
      #node_config.vm.box_url = 'https://atlas.hashicorp.com/' + node_config.vm.box + '.box'
      node_config.vm.box_url = 'https://atlas.hashicorp.com/' + node_config.vm.box
      node_config.vm.hostname = node[:hostname] + '.' + domain
      node_config.vm.network :private_network, ip: node[:ip]

      if node[:fwdhost]
        node_config.vm.network :forwarded_port, guest: node[:fwdguest], host: node[:fwdhost]
      end

#      if node[:hostname]  == "puppet"
#      	node_config.vm.network  "public_network", bridge: 'en1: Wi-Fi'
#      end

      memory = node[:ram] ? node[:ram] : 4096;
      node_config.vm.provider :virtualbox do |vb|
        vb.customize [
          'modifyvm', :id,
          '--name', node[:hostname],
          '--memory', memory.to_s,
          '--cpus', 2
        ]
      end

      node_config.vm.provision :puppet do |puppet|
        puppet.manifests_path = 'provision/manifests'
        puppet.module_path = 'provision/modules'
      end
    end
  end
end
