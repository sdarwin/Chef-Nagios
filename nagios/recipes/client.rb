#
# Author:: Joshua Sierles <joshua@37signals.com>
# Author:: Joshua Timberman <joshua@opscode.com>
# Author:: Nathan Haneysmith <nathan@opscode.com>
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: client
#
# Copyright 2009, 37signals
# Copyright 2009-2011, Opscode, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

if node['platform_family'] == "debian"
  execute "apt-get update" do
#      action :nothing
      not_if do
        ::File.exists?('/var/lib/apt/periodic/update-success-stamp') &&
        ::File.mtime('/var/lib/apt/periodic/update-success-stamp') > Time.now - 86400*2
      end
  end
end

mon_host = ['127.0.0.1']

#S.D. slight logic change here, add other mon hosts to server also
if node.run_list.roles.include?(node['nagios']['server_role'])
  mon_host << node['ipaddress']
end
if node['nagios']['multi_environment_monitoring']
  search(:node, "role:#{node['nagios']['server_role']}") do |n|
   mon_host << n['ipaddress'] unless mon_host.include?(n['ipaddress'])
  end
else
  search(:node, "role:#{node['nagios']['server_role']} AND chef_environment:#{node.chef_environment}") do |n|
    mon_host << n['ipaddress'] unless mon_host.include?(n['ipaddress'])
  end
end

include_recipe "nagios::client_#{node['nagios']['client']['install_method']}"

remote_directory node['nagios']['plugin_dir'] do
  source "plugins"
  owner "root"
  group "root"
  mode 0755
  files_mode 0755
end

directory "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d" do
  owner "root"
  group "root"
  mode 0755
end

template "#{node['nagios']['nrpe']['conf_dir']}/nrpe.cfg" do
  source "nrpe.cfg.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :mon_host => mon_host,
    :nrpe_directory => "#{node['nagios']['nrpe']['conf_dir']}/nrpe.d"
  )
  notifies :restart, "service[nagios-nrpe-server]"
end

case node['platform']
when "redhat","centos","fedora","scientific"
#2012 S.D. , not the case with RH 5???
#  if node[:platform_version].to_f < 6.0
#        nrpe_name = "nagios-nrpe-server"
#  else
#        nrpe_name = "nrpe"
#  end

   nrpe_name = "nrpe"

else
  nrpe_name = "nagios-nrpe-server"
end

service "nagios-nrpe-server" do
  service_name nrpe_name
  action [:start, :enable]
  supports :restart => true, :reload => true
end

# Use NRPE LWRP to define a few checks
nagios_nrpecheck "check_load" do
  command "#{node['nagios']['plugin_dir']}/check_load"
  warning_condition node['nagios']['checks']['load']['warning']
  critical_condition node['nagios']['checks']['load']['critical']
  action :add
end

nagios_nrpecheck "check_all_disks" do
  command "#{node['nagios']['plugin_dir']}/check_disk"
  warning_condition "8%"
  critical_condition "5%"
  parameters "-A -x /dev/shm -X nfs -i /boot"
  action :add
end

nagios_nrpecheck "check_users" do
  command "#{node['nagios']['plugin_dir']}/check_users"
  warning_condition "20"
  critical_condition "30"
  action :add
  notifies :restart, "service[nagios-nrpe-server]"
end

