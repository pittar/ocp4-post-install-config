# OpenShift 4: Post Installation Config

This repo contains scripts and files to bring a new OCP4 cluster up to a useful base configuration.

## Let's Encrypt

Use [Let's Encrypt](https://letsencrypt.org/) to generate good certs for your OCP4 cluster.  Based on [this blog post](https://blog.openshift.com/requesting-and-installing-lets-encrypt-certificates-for-openshift-4/).

You will need:
1. An AWS IAM user key/secret that has access to Route53.

Steps:
1. Make sure you're logged into the cluster as `system:admin`
2. Run `configure-certs.sh` from the same terminal window.
3. When prompted, paste in your AWS key and secret.  
4. Done!

This will clone the `acme.sh` repo and add your AWS key/secret to the `dns_aws.sh` file.  After this repo has been cloned once, you can skip this step by entering empty values for aws key and secret when prompted.