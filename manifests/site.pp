# This is the base node definition that all additional nodes should inherit.
node base {
  include ssh
  include puppet

  class { 'ssh::config' :
    port => '333',
    authorized_keys => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPhUQOT67Wo+ZR6FseUT35RN+W8EANXDlBT52oGJHD0N2QoZo8vmYnLO1w4EtLYAf6HLhgxGRwZP816KnW9w6pUnU1HEsfAEb/AmbL4xeiZfC/Tc39Rs9h+/o/NQeP7j7mHmuAnLSrCALFGUYF7IxvxAtudG799YLPeYKhqK7JClIxjgJ3Ax5yHgqbP8SasnNwEELOoHb8GMKKqZXB0ECNVB+1EwKgu6T5KIaVWM4ZXfrsliR6F1kympFiBRaU7YdWWgOHFtWxZnD6tU6HXhJn+6Ni7rXwwogjD0QUTeFBuKZJaagodEXP2DgjIMWcchaOPiZNtOe0oGY4Qh1umaVt kevin@cyberswat.com'],
  }
}

node /^puppet.cyberswat.com$/ inherits base {
  include puppet::master
}

node /^www.cyberswat.com$/ inherits base {
  include nginx
  class { 'nginx::config' :
    listen => 80,
    server_name => '.cyberswat.com',
    root => '/var/www/html'
  }
}

node /^li220-252.members.linode.com$/ {
  include ssh
  include puppet
  include devops
  class { devops::config :
    home => '/root',
  }
}

