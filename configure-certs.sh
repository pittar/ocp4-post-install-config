#!/bin/bash

# Code adapted from https://blog.openshift.com/requesting-and-installing-lets-encrypt-certificates-for-openshift-4/

LOGGED_IN=`oc whoami | grep 'system:admin'`
CLUSTER=`oc whoami --show-server`

LOGGED_IN=1
CLUSTER="blarg"

CERTS_DIR="$HOME/certs/ocp4"

# Make sure user is logged in as system:admin
if [ $LOGGED_IN ]; then
    echo "Logged in to OCP4 cluster $CLUSTER as system:admin."
else
    echo "You need to be logged in as system:admin."
    exit 1;
fi

# Get AWS ID and key for account that can access Route53.
echo -n "AWS Access Key ID: "
read AWS_ACCESS_KEY_ID
echo -n "AWS Secret Access Key: "
read AWS_SECRET_ACCESS_KEY

if [ $AWS_ACCESS_KEY_ID ]; then
    echo "Skip clone acme."
    # Make a dir for certs.
    rm -rf $CERTS_DIR
    mkdir -p $CERTS_DIR
    cd $CERTS_DIR

    # Clone latest acme script.
    git clone https://github.com/neilpang/acme.sh

    # Add access id and key. 
    sed -i '' '2i\ 
    AWS_ACCESS_KEY_ID="'$AWS_ACCESS_KEY_ID'" ' $CERTS_DIR/acme.sh/acme.sh/dnsapi/dns_aws.sh
    sed -i '' '3i\ 
    AWS_SECRET_ACCESS_KEY="'$AWS_SECRET_ACCESS_KEY'" ' $CERTS_DIR/acme.sh/acme.sh/dnsapi/dns_aws.sh
else
    cd $CERTS_DIR
fi

# Get API Server url and the apps wildcard url.
LE_API=$(oc whoami --show-server | cut -f 2 -d ':' | cut -f 3 -d '/' | sed 's/-api././')
LE_WILDCARD=$(oc get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.domain}')

echo "Path: $(pwd)"
echo "API url: $LE_API"
echo "APPS url: $LE_WILDCARD"

# Run acme.
acme.sh/acme.sh --issue -d $LE_API -d *.$LE_WILDCARD --dns dns_aws

# Set and create a permanent cert dir.
FINAL_CERT_DIR=$HOME/certs/ocp4/latest
mkdir -p $FINAL_CERT_DIR; 

# Move certs to new dir.
acme.sh/acme.sh --install-cert -d $LE_API -d *.$LE_WILDCARD --cert-file $FINAL_CERT_DIR/cert.pem --key-file $FINAL_CERT_DIR/key.pem --fullchain-file $FINAL_CERT_DIR/fullchain.pem --ca-file $FINAL_CERT_DIR/ca.cer

# Create a secret for the new certs and patch the router.
oc create secret tls router-certs --cert=$FINAL_CERT_DIR/fullchain.pem --key=$FINAL_CERT_DIR/key.pem -n openshift-ingress
oc patch ingresscontroller default -n openshift-ingress-operator --type=merge --patch='{"spec": { "defaultCertificate": { "name": "router-certs" }}}'
