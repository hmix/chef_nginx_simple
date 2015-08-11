#
# Cookbook Name:: nginx_simple
# Recipe:: server
#
# Copyright (c) 2015 Michael Haas, Apache License 2.0.

include_recipe 'apt' if node['platform_family'] == 'debian'

# Add ssl/tls certificates
if node.chef_environment == 'production'
  include_recipe 'certificate'
  certificate_manage node['fqdn'] do
    nginx_cert true
    search_id node['fqdn']
    cert_file "#{node['fqdn']}.pem"
    key_file "#{node['fqdn']}.key"
    chain_file "#{node['fqdn']}-bundle.crt"
  end
else
  # Use wildcard cert when using dev or test envrionment
  include_recipe 'certificate::wildcard'
  certificate_manage 'wildcard' do
    nginx_cert true
    search_id 'wildcard'
    cert_file 'wildcard.pem'
    key_file 'wildcard.key'
    chain_file 'wilcard-bundle.crt'
  end
end

# Add repository
case node['platform_family']
when 'debian'
  apt_repository 'nginx' do
    uri 'http://nginx.org/packages/debian/'
    components ['nginx']
    distribution node['lsb']['codename']
    key '4C2C 85E7 05DC 7308 3399 0C38 A937 6139 A524 C53E'
    keyserver 'pgp.mit.edu'
end
when 'rhel'
  yum_repository 'nginx' do
    baseurl 'http://nginx.org/packages/centos/$releasever/$basearch/'
    description 'CentOS $releasever - Nginx Community - Nginx'
    enabled true
    gpgcheck true
    gpgkey 'http://nginx.org/keys/nginx_signing.key'
  end
end

package 'nginx'

# Create document root
case node['platform_family']
when 'debian'
  httpd_user = 'www-data'
when 'rhel'
  httpd_user = 'nginx'
end

directory '/var/www/html' do
  owner httpd_user
  group httpd_user
  mode '0755'
  recursive true
end

# Include dummy index.html
template '/var/www/html/index.html' do
  source 'index.html.erb'
  owner httpd_user
  group httpd_user
  mode '0644'
end

case node['platform_family']
when 'debian'
  service 'nginx' do
    provider Chef::Provider::Service::Init::Debian
    supports status: true, restart: true, reload: true
    action [:enable, :restart]
  end
when 'rhel'
  service 'nginx' do
    provider Chef::Provider::Service::Init::Redhat
    supports status: true, restart: true, reload: true
    action [:enable, :start]
  end
end

# Add logrotation for nginx logs
include_recipe 'logrotate'
logrotate_app 'nginx_simple' do
  path "#{node['nginx_simple']['log_dir']}/*.log"
  enable true
  frequency 'daily'
  maxsize 51_200
  create '644 root adm'
end

