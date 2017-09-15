scriptsDir = $scriptsDir ||= File.expand_path("scripts", File.dirname(__FILE__))

setupScriptPath = scriptsDir + '/bootstrap_provisioning.sh'
setupScriptPathPhp70 = scriptsDir + '/bootstrap_provisioning_php70.sh'
setupDbScriptPath = scriptsDir + '/bootstrap_db_provisioning.sh'
afterScriptPath = scriptsDir + '/after_provisioning.sh'

Vagrant.configure("2") do |config|

     # Database Machine
     config.vm.define "mysql" do |db|

        # Specify the base box
        # Ubuntu
        db.vm.box = "boxcutter/ubuntu1604"
        db.vm.box_version = "= 2.0.26"

        db.vm.network :forwarded_port, guest: 3306, host: 3306, auto_correct: true
        db.vm.network :forwarded_port, guest: 22, host: 8022, auto_correct: true
        db.vm.network :private_network, ip: "10.0.0.10"

	    #db.vm.synced_folder ".", "/home/vagrant/app", type: "rsync", rsync__exclude: ".git/", rsync__auto: true
	    db.vm.synced_folder ".", "/home/vagrant/app", nfs: true
        db.vm.hostname = "mysql"

        # VM specific configs
        db.vm.provider "virtualbox" do |v|
            v.name = "mysql"
            v.customize ["modifyvm", :id, "--memory", "2048"]
            v.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
            v.customize ["modifyvm", :id, "--ioapic", "on"]
            v.customize ["modifyvm", :id, "--vram", "256"]
        end

        if File.exists? setupScriptPath then
            config_type= "mysql"
            config_name= "mysql"
            db.vm.provision "shell", path: setupDbScriptPath, :args => [config_type, config_name], privileged: false
        end
     end

     # Laravel Lumnen Machine
     config.vm.define "laravel" do |laravel|

        #aws Specific
        laravel.vm.box = "mvbcoding/awslinux"
        laravel.vm.box_version = "2017.03.0.20170401"

        # laravel.vbguest.auto_update = false

        laravel.vm.network :forwarded_port, guest: 8080, host: 4780, auto_correct: true

        laravel.vm.network :forwarded_port, guest: 4430, host: 5430, auto_correct: true
        laravel.vm.network :private_network, ip: "10.0.0.11"

	      laravel.vm.synced_folder ".", "/var/www/html/app", id: "vagrant-laravel", nfs: true
        laravel.vm.hostname = "laravel"

        # Assign correct permissions to storgae directory
        laravel.vm.synced_folder "./sourcecode/gateway/storage", "/var/www/html/app/sourcecode/gateway/storage",
            id: "vagrant-root-gateway",
            owner: "vagrant",
            group: "games",
            mount_options: ["dmode=777,fmode=777"],
            create: true

         # VM specific configs
         laravel.vm.provider "virtualbox" do |v|
            v.name = "laravel"
            v.customize ["modifyvm", :id, "--memory", "2048"]
            v.customize ["modifyvm", :id, "--cpuexecutioncap", "100"]
            v.customize ["modifyvm", :id, "--ioapic", "on"]
            v.customize ["modifyvm", :id, "--vram", "256"]
            v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
         end

         config_type= "app"
         config_name= "laravel"

         if File.exists? setupScriptPathPhp70 then
             laravel.vm.provision "shell", path: setupScriptPathPhp70, :args => [config_type, config_name], privileged: false
         end

         if File.exists? setupScriptPath then
             laravel.vm.provision "shell", path: setupScriptPath, :args => [config_type, config_name], privileged: false
         end

         if File.exists? afterScriptPath then
             laravel.vm.provision "shell", path: afterScriptPath, :args => [config_type, config_name], privileged: false
         end
     end
end
