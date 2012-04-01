node default {
  include devops
  class { devops::config :
    home => '/root',
  }
}

