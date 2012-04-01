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


}

