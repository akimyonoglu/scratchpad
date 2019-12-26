Vagrant.configure("2") do |config|
    
    config.vm.box = "hashicorp/bionic64"
    config.vm.hostname = "scratchpad.box"
    
    config.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 2
    end
    
    config.vm.provision :shell, path: "bootstrap.sh"
    config.vm.synced_folder "src/", "/home/vagrant/src"
    
    config.trigger.after [:provision] do |t|
        t.name = "Reboot after provisioning"
        t.run = { :inline => "vagrant reload" }
    end
end

