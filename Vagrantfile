# -*- mode: ruby -*-
# vi: set ft=ruby :

# Variables
IMAGE_NAME_K8S  = "bento/ubuntu-18.04"
PLAYBOOK_DIR = "/vagrant/ansible"
ROLES_DIR = "/vagrant/ansible/roles"
ANSIBLE_INVENTORY = "#{PLAYBOOK_DIR}" + '/inventory/hosts'

# Generate ssh keys for K8S further usage
#system("
#    if [ #{ARGV[0]} = 'up' ]; then
#        echo '!!! You are trying to spin up k8s Lab system starting generate ssh key for further use !!!'
#        src/scripts/local/make-ssh-key.sh
#    fi
#")

lab = {
  "mk8s-master"  => { :osimage => IMAGE_NAME_K8S,  :ip => "192.168.56.2",  :cpus => 2,  :mem =>3000,  :custom_host => "mk8s-master.sh"  },
  "mk8s-worker1" => { :osimage => IMAGE_NAME_K8S,  :ip => "192.168.56.10", :cpus => 2,  :mem =>3000,  :custom_host => "mk8s-worker1.sh" },
  "mk8s-worker2" => { :osimage => IMAGE_NAME_K8S,  :ip => "192.168.56.11", :cpus => 2,  :mem =>3000,  :custom_host => "mk8s-worker2.sh" }
  }

Vagrant.configure("2") do |config|
  lab.each_with_index do |(hostname, info), index|
    config.vm.define hostname do |cfg|

      # Synchronization apps/ dir into destination /vagrant dir (needed for deploy application into K8s cluster)
      config.vm.synced_folder '.', '/vagrant',
      type: 'rsync',
      # rsync__verbose: true,
      rsync__exclude: [
        'extrastorage', 'src', '.gitignore',
        'README.md', 'Vagrantfile', '.vagrant', 
        '.git',
      ]

      # Allow login ssh use password also
      cfg.vm.provision "shell", inline: "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config;systemctl restart sshd", privileged: true

      # Define motd
      cfg.vm.provision "shell", path: "src/scripts/provisioning/#{info[:custom_host]}", privileged: true

      # Propagate ssh keys in case of further ansible usage
      cfg.vm.provision "ansible_local" do |ansible|
        ansible.verbose = true
        ansible.install = true
        ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'ssh-key.yaml'
        ansible.galaxy_roles_path = "#{ROLES_DIR}"
      end # end ssh key propagation

      # Prepare /etc/hosts adopt entries interconnect cluster
      cfg.vm.provision "ansible_local" do |ansible|
        ansible.verbose = true
        ansible.install = true
        ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-hosts.yaml'
        ansible.galaxy_roles_path = "#{ROLES_DIR}"
      end # end hosts file preparation

      if (hostname == 'mk8s-master') or (hostname == 'mk8s-worker1') or (hostname == 'mk8s-worker2') or (hostname == 'mk8s-worker3') then
        # Prerequisite ansible playbooks for kubernetes
        cfg.vm.provision "ansible_local" do |ansible|
            ansible.verbose = "v"
            ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-prereq.yaml'
            ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # Kubernetes end ansible playbook runs
      end

      # Initialize first control plane and give possibility to upload keys
      if (hostname == 'mk8s-master') then
        # k8s bootstrapping master
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-bootstrap-master.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end master bootstrapping
      end

      if (hostname == 'mk8s-worker1') or (hostname == 'mk8s-worker2') then

        # Download join script from master previously generated - compute functionality
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-pull-join-worker.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
          ansible.inventory_path = "#{ANSIBLE_INVENTORY}"
          ansible.limit = "mk8s-master"
        end # end pull join.sh from master

        # k8s bootstrapping worker
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-bootstrap-worker.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end worker bottstrapping

        # k8s join worker
        cfg.vm.provision "ansible_local" do |ansible|
          ansible.verbose = "v"
          ansible.playbook = "#{PLAYBOOK_DIR}" + '/' + 'k8s-join-worker.yaml'
          ansible.galaxy_roles_path = "#{ROLES_DIR}"
        end # end worker joining

      end # End host selection

      # start first run privider
      cfg.vm.provider :virtualbox do |vb, override|

        # Memory, CPU, Image configuration
        vb.memory = "#{info[:mem]}"
        vb.cpus = "#{info[:cpus]}"
        config.vm.box = info[:osimage]

        override.vm.network :private_network, ip: "#{info[:ip]}"

        # Configure hostname
        override.vm.hostname = hostname

      end # end provider
    end # end config
  end # end lab
end
