This sets up a dev environment for cloud systems engineering.  In order to start you need to spin up an Ubuntu Lucid 10.04 LTS instance.

Installation
-----------
Once you have a working Lucid installation run:

    apt-get install git-core -y && git clone git://github.com/cyberswat/dev-ops.git /etc/puppet && /etc/puppet/setup.sh

You will be prompted to enter your svn username and password after puppet has completed it's run.  Once svn has finished it's checkouts exit your terminal session and log back in to ensure a working environment.

Upload your hosting-dev folder to ~/secure/ec2/hosting-dev and your system-tests folder to ~/secure/ec2/system-tests.  Ensure the relevant files contained in those folders have the correct permissions.

    chmod 0400 ~/secure/ec2/hosting-dev/ssh/default && chmod 0400 ~/secure/ec2/system-tests/ssh/default && chmod 0400 ~/secure/ec2/hosting-dev/netrc

Now that all of the pre-requisites are in place we need to identify an account and stage.  Replace cyberswat with your name.

    facct hosting-dev && fstage cyberswat

Once the stage is set up we need to launch a master instance.

    cd ~/apps/acquia/engineering/fields/trunk/master-instance && rake run

When you are done with the master instance you can stop it with

    cd ~/apps/acquia/engineering/fields/trunk/master-instance && rake stop

