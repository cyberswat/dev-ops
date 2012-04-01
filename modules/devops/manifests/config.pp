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
    source => "puppet:///devops/bashrc",
    ensure => present,
    mode => 0644,
  }

}

