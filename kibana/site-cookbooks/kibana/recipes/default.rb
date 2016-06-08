#
# Cookbook Name:: monit-rpm
# Recipe:: default
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

RPM_FILE='kibana-4.5.1-1.x86_64.rpm'
RPM_FILE_PATH="/tmp/#{RPM_FILE}"
RPM_URL="https://download.elastic.co/kibana/kibana/#{RPM_FILE}"


bash 'kibana install' do
  user "root"
  cwd "/tmp"
  code <<-EOC
  wget #{RPM_URL}
  rpm -ivh #{RPM_FILE_PATH}
  EOC
  notifies :restart, 'service[kibana]'
end

service "kibana" do
  action [:enable]
  supports :start => true, :status => true, :restart => true
end
