This sets up a dev environment for cloud systems engineering.  In order to start you need to spin up an Ubuntu Lucid 10.04 LTS instance.

Installation
-----------
Once you have a working Lucid installation run:

    apt-get install git-core -y && git clone git://github.com/cyberswat/dev-ops.git /etc/puppet && /etc/puppet/setup.sh

You will be prompted to enter your svn username and password after puppet has completed it's run.  Once svn has finished it's checkouts exit your terminal session and log back in to ensure a working environment.

