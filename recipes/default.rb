#
# Cookbook Name:: lxc
# Recipe:: default
#
# Copyright 2010, Company
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


package 'debootstrap'

host = node[:container]


directory host[:base_directory] do
  action :create
  mode 0755
  owner 'root'
  group 'root'
end


search(:virtual_machines) do |guest|
  # Bootstrap
  domain = guest[:domain] || host[:default][:domain]
  hostname = "#{guest[:id]}.#{domain}"

  variant = guest[:variant] || host[:default][:variant]
  suite   = guest[:suite  ] || host[:default][:suite  ]
  mirror  = guest[:mirror ] || host[:default][:mirror ]
  rootfs  = host[:base_directory] / hostname + '.rootfs'

  execute "debootstrap" do
    command "debootstrap --variant=#{variant} #{suite} #{rootfs} #{mirror}"
    action :run
    not_if "test -f #{rootfs / 'etc' / 'issue'}"
  end

  template host[:base_directory] / hostname + '.lxc.conf' do
    source "lxc.conf.erb"
    variables :host => host, :guest => guest, :rootfs => rootfs, :hostname => hostname
    action :create
  end
end
