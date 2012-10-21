
package "apache2" do
  case node['platform']
  when "redhat","centos","scientific","fedora","suse","amazon","arch"
  package_name "httpd"
  when "debian","ubuntu"
  package_name "apache2"
  when "freebsd"
  package_name "apache22"
  end
  action :install
  notifies :run, "execute[a2enmod-rewrite]"
  notifies :run, "execute[a2enmod-ssl]"
end

#all this code with "notifies" has not been tested.  we don't want these actions to run until the package has been installed
execute "a2enmod-rewrite" do
command "/usr/sbin/a2enmod rewrite" 
action :nothing
only_if node['platform_family'] == "debian"
creates "/etc/apache2/mods-enabled rewrite.load"
end

execute "a2enmod-ssl" do
command "/usr/sbin/a2enmod ssl" 
action :nothing
only_if node['platform_family'] == "debian"
creates "/etc/apache2/mods-enabled ssl.load"
end

service "apache2" do
  case node['platform']
  when "redhat","centos","scientific","fedora","suse","amazon"
    service_name "httpd"
    # If restarted/reloaded too quickly httpd has a habit of failing.
    # This may happen with multiple recipes notifying apache to restart - like
    # during the initial bootstrap.
    restart_command "/sbin/service httpd restart && sleep 1"
    reload_command "/sbin/service httpd reload && sleep 1"
  when "debian","ubuntu"
    service_name "apache2"
    restart_command "/usr/sbin/invoke-rc.d apache2 restart && sleep 1"
    reload_command "/usr/sbin/invoke-rc.d apache2 reload && sleep 1"
  when "arch"
    service_name "httpd"
  when "freebsd"
    service_name "apache22"
  end
  supports value_for_platform(
    "debian" => { "4.0" => [ :restart, :reload ], "default" => [ :restart, :reload, :status ] },
    "ubuntu" => { "default" => [ :restart, :reload, :status ] },
    "redhat" => { "default" => [ :restart, :reload, :status ] },
    "centos" => { "default" => [ :restart, :reload, :status ] },
    "scientific" => { "default" => [ :restart, :reload, :status ] },
    "fedora" => { "default" => [ :restart, :reload, :status ] },
    "arch" => { "default" => [ :restart, :reload, :status ] },
    "suse" => { "default" => [ :restart, :reload, :status ] },
    "freebsd" => { "default" => [ :restart, :reload, :status ] },
    "amazon" => { "default" => [ :restart, :reload, :status ] },
    "default" => { "default" => [:restart, :reload ] }
  )
  action :enable
end

service "apache2" do
  action :start
end

