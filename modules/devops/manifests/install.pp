# == Class: dev::install
#
# Creates an Acquia ops development environment.
#
# === Parameters
#
class devops::install inherits devops::params {
  # Set paths for later use.
  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/rvm/bin',
  }

  # Install the non-interactive packages that exist in standard repos.
  devops::packages { [
    "python-software-properties",
    "openssl",
    "libopenssl-ruby",
    "python-openssl",
    "php-pear",
    "php5-curl",
    "ruby-dev",
    "curl",
    "sqlite3",
    "libsqlite3-dev",
    "libreadline6",
    "libreadline6-dev",
    "build-essential",
    "git-core",
    "zlib1g-dev",
    "libssl-dev",
    "libyaml-dev",
    "libsqlite3-0",
    "libxml2-dev",
    "autoconf",
    "libc6-dev",
    "automake",
    "libtool",
    "bison",
    "libxmltok1-dev",
    "php5-cli",
    "subversion",
    "libgcrypt11-dev",
    "libexpat1-dev",
    "libmysqlclient-dev",
  ]: }

  # Sun has an interactive installer so we generate a seed file and feed it to 
  # dpkg as the response.  `debconf-get-selections | grep sun-` generates seed.
  file { "/var/cache/debconf/sun-java6-jdk.seeds":
    source => "puppet:///modules/devops/sun-java6-jdk.seeds",
    ensure => present;
  }
  package { "sun-java6-jdk":
    require      => File["/var/cache/debconf/sun-java6-jdk.seeds"],
    responsefile => "/var/cache/debconf/sun-java6-jdk.seeds",
    ensure       => present;
  }

  # Use pear to install XML_RPC - note XML_RPC is deprecated in favor of XML_RPC2.
  exec { "pear install XML_RPC-1.5.4":
    onlyif => ["test ! -d /usr/share/php/test/XML_RPC", "test -f /usr/bin/pear"]
  }
 
  # Remove the rvm install script if necessary.
  file { '/tmp/rvm':
    ensure  => absent,
    require => Exec['install-rvm'],
  }

  # Run the rvm installer if we need to. 
  exec { 'php-cli-mod':
    command => "/bin/sed -i 's/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g' /etc/php5/cli/php.ini",
  }

}

# Define helper for standard packages.
define devops::packages() {
  package { "${name}":
    ensure => present,
  }
}

# Define helper for directory creation.
define devops::directories() {
  file { "${name}":
    ensure => "directory",
  }
}

