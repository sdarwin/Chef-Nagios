#
# Author:: Seth Chisamore <schisamo@opscode.com>
# Cookbook Name:: nagios
# Recipe:: server_package
#
# Copyright 2011, Opscode, Inc
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

case node['platform']
when "redhat","centos","fedora","scientific"
  template "/etc/yum.repos.d/epel.repo" do
    source "epel.repo.erb"
    mode 0644
    owner "root"
    group "root"
  end
end

pkgs = value_for_platform(
   [ "centos", "redhat", "fedora" ] => {
        "default" => %w{ nagios nagios-plugins-nrpe }
        },
  [ "debian", "ubuntu" ] => {
    "default" => %w{ nagios3 nagios-nrpe-plugin nagios-images }
  },
  "default" => %w{ nagios3 nagios-nrpe-plugin nagios-images }
)

pkgs.each do |pkg|
  package pkg do
    action :install
  end
end

#2012, notice that dir is missing
case node['platform']
when "redhat","centos","fedora","scientific"

 directory "/var/lib/nagios/spool" do
   path "#{node['nagios']['state_dir']}/spool"
   owner "root"
   group "root"
   mode "0755"
   action :create
 end

 directory "/var/lib/nagios/spool/checkresults" do
   path "#{node['nagios']['state_dir']}/spool/checkresults"
   owner "nagios"
   group "nagios"
   mode "0775"
   action :create
 end

 file "/etc/nagios/conf.d/internet.cfg" do
   path "#{node['nagios']['config_dir']}/internet.cfg"
   action :delete
 end

 directory "/var/cache/nagios" do
   path "#{node['nagios']['cache_dir']}"
   owner "nagios"
   group "nagios"
   mode "0755"
   action :create
 end

file "/etc/nagios/resource.cfg" do
   path "#{node['nagios']['conf_dir']}/resource.cfg"
   owner "nagios"
   group "nagios"
   mode "0660"
   action :create
 end

 directory "/var/run/nagios" do
   path "#{node['nagios']['run_dir']}"
   owner "nagios"
   group "nagios"
   mode "0755"
   action :create
 end

end

#%w{ 
#  nagios3
#  nagios-nrpe-plugin
#  nagios-images
#}.each do |pkg|
#  package pkg
#end

