file_name="kibana-3.1.2"
remote_uri="https://download.elastic.co/kibana/kibana/#{file_name}.zip"


yum_package 'unzip' do
  action  :install
end

bash "install_kibana" do
  only_if { !File.exists?('/user/share/elasticsearch/plugins/kibana') }
  user "root"
  cwd "/tmp"
  code <<-EOH
  wget #{remote_uri}
  mkdir -p /usr/share/elasticsearch/plugins/kibana/_site
  unzip /tmp/#{file_name}.zip
  cp -rf /tmp/#{file_name}/* /usr/share/elasticsearch/plugins/kibana/_site
  EOH
end

bash "install_kopf" do
  only_if { !File.exists?('/user/share/elasticsearch/plugins/kopf') }
  user "root"
  cwd "/tmp"
  code <<-EOH
  /usr/share/elasticsearch/bin/plugin -install lmenezes/elasticsearch-kopf/v1.4.9
  EOH
end
