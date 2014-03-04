#
# Cookbook Name:: ossec
# Recipe:: server
#
# Copyright 2010, Opscode, Inc.
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

node.set['ossec']['user']['install_type'] = "server"
node.set['ossec']['server']['maxagents']  = 1024

include_recipe "ossec"

agent_manager = "#{node['ossec']['user']['dir']}/bin/ossec-batch-manager.pl"

file "#{node['ossec']['user']['dir']}/etc/client.keys" do
  owner 'root'
  group 'ossec'
  mode 0644
end

bash 'configure authd' do
    code <<-EOF
            openssl genrsa -out /var/ossec/etc/sslmanager.key 2048
            openssl req -new -x509 -key /var/ossec/etc/sslmanager.key -out /var/ossec/etc/sslmanager.cert -days 365 -batch
          EOF
end

service "ossec" do
  action :restart
end

bash 'start authd' do
  code <<-EOF
    /var/ossec/bin/ossec-authd -p 1515 >/dev/null 2>&1 &
  EOF
end
