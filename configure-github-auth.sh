#!/bin/bash

LOGGED_IN=`oc whoami | grep 'system:admin'`
CLUSTER=`oc whoami --show-server`

# Make sure user is logged in as system:admin
if [ $LOGGED_IN ]; then
    echo "Logged in to OCP4 cluster $CLUSTER as system:admin."
else
    echo "You need to be logged in as system:admin."
    exit 1;
fi

# Get Github ID and key for the Org that will be used for auth.
echo -n "Github Client ID: "
read GITHUB_CLIENT_ID
echo -n "Github Client Key: "
read GITHUB_CLIENT_KEY

# Create secret with client key.
oc create secret generic github-auth-secret --from-literal=clientSecret=$GITHUB_CLIENT_KEY -n openshift-config
# Create OAuth custom resource.
oc apply -f githubauth.yaml
