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

## Github Auth

** NOT READY - UNTESTED**

To add Github authentication to your cluster:
1. Follow [these steps](https://docs.openshift.com/container-platform/4.1/authentication/identity_providers/configuring-github-identity-provider.html#identity-provider-registering-github_configuring-github-identity-provider) to register a Github application.
    * `Homepage URL` can point to your console, for example `https://console-openshift-console.apps.<cluster name>.<cluster domain>`
    * `OAuth URL` should look like this: `https://oauth-openshift.apps.<cluster-name>.<cluster-domain>/oauth2callback/<idp-provider-name>
`.  **idp-provider-name** can be whatever you like, but **github** makes sense.
    * Take note of **Client ID** and **Client Secret**.
2. Make a copy of `resources/githubauth.yaml` and update with your client ID and Github org.  Move the file to the same dir where your script lives.
3. Run `configure-github-auth.sh`

If all goes well, you should have Github as an identity provider when you login.


## HTPasswd Auth (thanks @gnunn1)

```
oc create secret generic htpass-secret --from-file=htpasswd=htpasswd -n openshift-config
oc apply -f htpasswd.yaml -n openshift-config
oc adm policy add-cluster-role-to-user cluster-admin admin
```

Make sure you have a secret locally defined (like below) and an `htpasswd` file with users and password hashes in the same directory.

```
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: htpasswd
    challenge: true 
    login: true 
    mappingMethod: claim 
    type: HTPasswd
    htpasswd:
      fileData:
        name: htpass-secret
```

You can create password hashes with a tool such as:
[https://www.htaccesstools.com/htpasswd-generator/](https://www.htaccesstools.com/htpasswd-generator/)
