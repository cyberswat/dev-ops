# == Class: devops::config
#
# Manages variables for the Acquia devops install.
#
# === Variables
#
# [*home*]
#   Optional: yes
#
# === Examples
#
#  class { 'devops::config' :
#    home => '/home/cyberswat'
#  }
#
class devops::config(
  $home  = '/root'
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
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/rvm/bin',
  }

  # Download the ec2-api-tools.
  exec { 'download-ec2-api-tools':
    command => 'wget -O /tmp/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip',
    creates => '/tmp/ec2-api-tools.zip',
    unless  => "test -d ${devops::config::home}/ec2-api-tools",
  }

  # Run the rvm installer if we need to. 
  exec { 'unzip-ec2-api-tools':
    command => "unzip -d ${devops::config::home}/apps/ /tmp/ec2-api-tools.zip",
    require => Exec['download-ec2-api-tools'],
    unless  => "test -d ${devops::config::home}/ec2-api-tools",
  }

  # Run the rvm installer if we need to. 
  exec { 'mv-ec2-api-tools':
    command => "mv ${devops::config::home}/apps/ec2-api-tools* ${devops::config::home}/ec2-api-tools",
    require => Exec['unzip-ec2-api-tools'],
    unless  => "test -d ${devops::config::home}/ec2-api-tools",
  }

}

