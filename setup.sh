#!/bin/bash
echo -e "deb http://apt.puppetlabs.com/ubuntu lucid main\ndeb-src http://apt.puppetlabs.com/ubuntu lucid main\ndeb http://ppa.launchpad.net/sun-java-community-team/sun-java6/ubuntu lucid main\ndeb-src http://ppa.launchpad.net/sun-java-community-team/sun-java6/ubuntu lucid main" >> /etc/apt/sources.list.d/acquia-devops.list && apt-key adv --keyserver keyserver.ubuntu.com --recv 4BD6EC30 && apt-key adv --keyserver keyserver.ubuntu.com --recv 3EBCE749 && apt-get update && apt-get install puppet -y
puppet apply /etc/puppet/manifests/site.pp && puppet apply /etc/puppet/manifests/site.pp
( cd $HOME/apps/acquia/engineering/itlib; svn co https://svn.acquia.com/repos/engineering/itlib/trunk )
( cd $HOME/apps/acquia/engineering/infrastructure; svn co https://svn.acquia.com/repos/engineering/infrastructure/trunk )
( cd $HOME/apps/acquia/engineering/fields; svn co https://svn.acquia.com/repos/engineering/fields/trunk)
