# deploy

## Setup if you have access to secret repositories

To check out all repositories in the correct place:

    git clone git@github.com:open-contracting/deploy.git open-contracting-deploy
    mkdir salt
    git clone git@github.com:open-contracting/deploy-salt-private.git salt/private
    mkdir pillar
    git clone git@github.com:open-contracting/deploy-pillar-private.git pillar/private
    
## Updating

You can run

    ./updateToMaster.sh
    
This will update all 3 repositories (public and 2 private ones) to the master branch and the latest version, 
whilst showing you the git messages so if there are any conflicts or problems switching you can see.

