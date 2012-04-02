node default {
  include devops
  class { devops::config :
    home => '/root',
    rvm_path => '/usr/local/rvm',
  }
}

