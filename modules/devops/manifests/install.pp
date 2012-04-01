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
    "libxslt-dev",
    "libyaml-dev",
    "libsqlite3-0",
    "libxml2-dev",
    "autoconf",
    "libc6-dev",
    "ncurses-dev",
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
 
  # Download the rvm installer if rvm is not known.
  exec { 'download-rvm-install':
    command => 'wget -O /tmp/rvm https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer',
    creates => '/tmp/rvm',
    path => '/usr/bin',
    unless  => 'test -f /usr/local/rvm/bin/rvm',
  }

  # Run the rvm installer if we need to. 
  exec { 'install-rvm':
    command => "bash /tmp/rvm",
    creates => '/usr/local/rvm/bin/rvm',
    require => Exec['download-rvm-install'],
  }

  # Remove the rvm install script if necessary.
  file { '/tmp/rvm':
    ensure  => absent,
    require => Exec['install-rvm'],
  }

  # Use rvm to install zlib
  exec { 'install-rvm-zlib':
    command => "rvm pkg install zlib",
    creates => '/usr/local/rvm/usr/lib/libz.so',
    require => Exec['install-rvm'],
  }

  # Use rvm to install opnssl
  exec { 'install-rvm-openssl':
    command => "rvm pkg install openssl",
    creates => '/usr/local/rvm/usr/lib/libssl.so',
    require => Exec['install-rvm'],
  }

  # Use rvm to install libxml2
  exec { 'install-rvm-libxml2':
    command => "rvm pkg install libxml2",
    creates => '/usr/local/rvm/usr/lib/libxml2.so',
    require => Exec['install-rvm'],
  }

  # Use rvm to install libxslt
  exec { 'install-rvm-libxslt':
    command => "rvm pkg install libxslt",
    creates => '/usr/local/rvm/usr/lib/libxslt.so',
    require => Exec['install-rvm'],
  }

  # Use rvm to install ruby 1.8.7
  exec { 'install-rvm-ruby':
    command => "rvm install 1.8.7 --with-openssl-dir=/usr/local/rvm/usr --with-zlib-dir=/usr/local/rvm/usr --with-libxml2-dir=/usr/local/rvm/usr --with-libxslt-dir=/usr/local/rvm/usr",
    creates => '/usr/local/rvm/rubies/ruby-1.8.7-p358',
    require => Exec['install-rvm'],
  }

  file { "/usr/local/bin/rvm-set-ruby":
    source => "puppet:///modules/devops/rvm-set-ruby",
    ensure => present,
    mode => 755,
  }

  # Use rvm to install ruby 1.8.7
  exec { 'set-rvm-ruby':
    command => "/usr/local/bin/rvm-set-ruby 1.8.7",
    onlyif => ["test -f /usr/local/bin/rvm-set-ruby", "test -f /usr/local/rvm/scripts/rvm"],
    require => Exec['install-rvm-ruby'],
  }

  # Install the non-interactive packages that exist in standard repos.
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

  # Download the ec2-api-tools.
  exec { 'download-ec2-api-tools':
    command => 'wget -O /tmp/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip',
    creates => '/tmp/ec2-api-tools.zip',
    path => '/usr/bin',
    unless  => 'test -d /root/ec2-api-tools',
  }

  # Run the rvm installer if we need to. 
  exec { 'unzip-ec2-api-tools':
    command => "unzip -d /root/apps/ /tmp/ec2-api-tools.zip",
    require => Exec['download-ec2-api-tools'],
    unless  => 'test -d /root/ec2-api-tools',
  }

  # Run the rvm installer if we need to. 
  exec { 'mv-ec2-api-tools':
    command => "/bin/mv /root/apps/ec2-api-tools* /root/ec2-api-tools",
    require => Exec['unzip-ec2-api-tools'],
    unless  => 'test -d /root/ec2-api-tools',
  }

  # Run the rvm installer if we need to. 
  #exec { 'php-cli-mod':
  #  command => "/bin/sed -i 's/GPCS/EGPCS/g' /etc/php5/cli/php.ini",
  #}

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

# Define helper for standard packages.
define devops::gems() {
  exec { "install-gems-${name}":
    command => "/usr/local/rvm/rubies/ruby-1.8.7-p358/bin/gem install ${name} --no-ri --no-rdoc",
    unless => "/usr/local/rvm/rubies/ruby-1.8.7-p358/bin/gem list | /bin/grep -c ${name}",
    onlyif => "test -f /usr/local/rvm/rubies/ruby-1.8.7-p358/bin/gem",
  }

}

