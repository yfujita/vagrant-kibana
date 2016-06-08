es_version = "2.3.2"
filename = "elasticsearch-#{es_version}.rpm"
remote_uri = "https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/rpm/elasticsearch/#{es_version}/#{filename}"

service "elasticsearch" do
    supports :status => true, :restart => true, :reload => true
end

remote_file "/tmp/#{filename}" do
    only_if { !File.exists?('/usr/share/elasticsearch') }
    source "#{remote_uri}"
    mode 00644
end

package "elasticsearch" do
    only_if { !File.exists?('/usr/share/elasticsearch') }
    action :install
    source "/tmp/#{filename}"
    provider Chef::Provider::Package::Rpm
end

bash "update_es_yml" do
  only_if { !File.exists?('/tmp/yml_updated') }
  user "root"
  cwd "/tmp"
  code <<-EOH
  cat /etc/elasticsearch/elasticsearch.yml > /tmp/elasticsearch.yml.tmp
  echo "cluster.name: elasticsearch" >> /tmp/elasticsearch.yml.tmp
  echo "node.name: \"ES Node 1\"" >> /tmp/elasticsearch.yml.tmp
  echo "index.number_of_shards: 1" >> /tmp/elasticsearch.yml.tmp
  echo "index.number_of_replicas: 0" >> /tmp/elasticsearch.yml.tmp
  echo "http.cors.enabled: true" >> /tmp/elasticsearch.yml.tmp
  echo 'http.cors.allow-origin: "*"' >> /tmp/elasticsearch.yml.tmp
  echo 'network.host: "0"' >> /tmp/elasticsearch.yml.tmp
  echo 'security.manager.enabled : false' >> /tmp/elasticsearch.yml.tmp
  echo 'index.max_result_window: 100000' >> /tmp/elasticsearch.yml.tmp
  echo 'script.groovy.sandbox.enabled: true' >> /tmp/elasticsearch.yml.tmp
  echo 'script.inline: on' >> /tmp/elasticsearch.yml.tmp
  echo 'script.indexed: on' >> /tmp/elasticsearch.yml.tmp
  mv -f /tmp/elasticsearch.yml.tmp /etc/elasticsearch/elasticsearch.yml
  touch /tmp/yml_updated
  EOH
  notifies :restart, resources(:service => "elasticsearch")
end

bash "install_kopf" do
  only_if { !File.exists?('/user/share/elasticsearch/plugins/kopf') }
  user "root"
  cwd "/tmp"
  code <<-EOH
  /usr/share/elasticsearch/bin/plugin install lmenezes/elasticsearch-kopf/master
  EOH
end
