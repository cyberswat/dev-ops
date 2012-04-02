# Home and rvm path will change if your installing as a non-root user.
node default {
  include devops
  class { devops::config :
    home => '/root',
    rvm_path => '/usr/local/rvm',
  }
}

