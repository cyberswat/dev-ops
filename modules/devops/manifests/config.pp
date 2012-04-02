# == Class: devops::config
#
# Manages the bits dependant on variable configs.
#
# === Variables
#
# [*home*]
#   Optional: yes
#
# [*home*]
#   Optional: yes
#
# === Examples
#
#  class { 'devops::config' :
#    home => '/home/cyberswat',
#    rvm_path => '/home/cyberswat/.rvm'
#  }
class devops::config(
  $home  = '/root',
  $rvm_path = '/usr/local/rvm',
) {

  # Create the directories we need.
  devops::directories { [
    "${devops::config::home}/apps",
    "${devops::config::home}/apps/acquia",
    "${devops::config::home}/apps/acquia/engineering",
    "${devops::config::home}/apps/acquia/engineering/itlib",
    "${devops::config::home}/apps/acquia/engineering/infrastructure",
    "${devops::config::home}/apps/acquia/engineering/fields",
    "${devops::config::home}/secure",
    "${devops::config::home}/secure/ec2",
  ]: }

  # Install a .bashrc file with our modifications.
  file { "${devops::config::home}/.bashrc":
    source => "puppet:///modules/devops/bashrc",
    ensure => present,
    mode => 0644,
  }

  # Install a .bash_profile file with our modifications.
  file { "${devops::config::home}/.bash_profile":
    source => "puppet:///modules/devops/bash_profile",
    ensure => present,
    mode => 0644,
  }

  # Install a .bash_logout file with our modifications.
  file { "${devops::config::home}/.bash_logout":
    source => "puppet:///modules/devops/bash_logout",
    ensure => present,
    mode => 0644,
  }

  # Set paths for later use.
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/rvm/bin:~/.rvm/bin',
  }

  # Download the ec2-api-tools if we need to.
  exec { 'download-ec2-api-tools':
    command => 'wget -O /tmp/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip',
    creates => '/tmp/ec2-api-tools.zip',
    unless  => "test -d ${devops::config::home}/ec2-api-tools",
  }

  # If we have downloaded the ec2 tools unzip them.
  exec { 'unzip-ec2-api-tools':
    command => "unzip -d ${devops::config::home}/apps/ /tmp/ec2-api-tools.zip",
    require => Exec['download-ec2-api-tools'],
    unless  => "test -d ${devops::config::home}/ec2-api-tools",
  }

  # If we have downloaded and unzipped ec2 tools move them to the correct location.
  exec { 'mv-ec2-api-tools':
    command => "mv ${devops::config::home}/apps/ec2-api-tools* ${devops::config::home}/ec2-api-tools",
    require => Exec['unzip-ec2-api-tools'],
    unless  => "test -d ${devops::config::home}/ec2-api-tools",
  }

  # Download the rvm installer if rvm is not known.
  exec { 'download-rvm-install':
    command => 'wget -O /tmp/rvm https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer',
    creates => '/tmp/rvm',
    unless  => "test -f ${devops::config::rvm_path}/bin/rvm",
  }

  # Run the rvm installer if we need to. Cleanup of this file happens in install.pp.
  exec { 'install-rvm':
    command => "bash /tmp/rvm",
    creates => "${devops::config::rvm_path}/bin/rvm",
    require => Exec['download-rvm-install'],
  }

  # Use rvm to install zlib
  exec { 'install-rvm-zlib':
    command => "rvm pkg install zlib",
    creates => "${devops::config::rvm_path}/usr/lib/libz.so",
    require => Exec['install-rvm'],
  }

  # Use rvm to install opnssl
  exec { 'install-rvm-openssl':
    command => "rvm pkg install openssl",
    creates => "${devops::config::rvm_path}/usr/lib/libssl.so",
    require => Exec['install-rvm'],
  }

  # Use rvm to install libxml2
  exec { 'install-rvm-libxml2':
    command => "rvm pkg install libxml2",
    creates => "${devops::config::rvm_path}/usr/lib/libxml2.so",
    require => Exec['install-rvm'],
  }

  # Use rvm to install libxslt
  exec { 'install-rvm-libxslt':
    command => "rvm pkg install libxslt",
    creates => "${devops::config::rvm_path}/usr/lib/libxslt.so",
    require => Exec['install-rvm'],
  }

  # Use rvm to install ruby 1.8.7
  exec { 'install-rvm-ruby':
    command => "rvm install 1.8.7 --with-openssl-dir=${devops::config::rvm_path}/usr --with-zlib-dir=${devops::config::rvm_path}/usr --with-libxml2-dir=${devops::config::rvm_path}/usr --with-libxslt-dir=${devops::config::rvm_path}/usr",
    creates => "${devops::config::rvm_path}/rubies/ruby-1.8.7-p358",
    require => Exec['install-rvm'],
  }

  # Use a helper script to `rvm use 1.8.7 --default`.
  exec { 'set-rvm-ruby':
    command => "/usr/local/bin/rvm-set-ruby 1.8.7",
    onlyif => ["test -f /usr/local/bin/rvm-set-ruby", "test -f ${devops::config::rvm_path}/scripts/rvm"],
    require => Exec['install-rvm-ruby'],
  }

  # Install the necessary gems.
  devops::gems { [
    "assertions",
    "capistrano",
    "configtoolkit",
    "ffi",
    "highline",
    "httpclient",
    "json_pure",
    "mumboe-soap4r",
    "net-netrc",
    "net-scp",
    "net-sftp",
    "net-ssh",
    "net-ssh-gateway",
    "nettica",
    "open4",
    "Platform",
    "popen4",
    "rake",
    "relative",
    "right_aws",
    "right_http_connection",
    "sqlite3",
    "sqlite3-ruby",
    "ruby-hmac",
    "escape",
    "mkrf",
    "xmlparser",
    "net-ssh-multi",
    "json",
    "mysql",
  ]: }

}

# Define helper for gem installation.
define devops::gems() {
  exec { "install-gems-${name}":
    command => "${devops::config::rvm_path}/rubies/ruby-1.8.7-p358/bin/gem install ${name} --no-ri --no-rdoc",
    unless => "${devops::config::rvm_path}/rubies/ruby-1.8.7-p358/bin/gem list | /bin/grep -c ${name}",
    onlyif => "test -f ${devops::config::rvm_path}/rubies/ruby-1.8.7-p358/bin/gem",
  }

}

