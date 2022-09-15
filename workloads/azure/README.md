# Azure Red Hat Openshift perfscale Scripts

The purpose of the script is to create/delete Azure Red Hat OpenShift.

Prerequisites, 
1. Install these OS packages - `curl`
2. Set other vars in `env.sh`

Run the script,
1. Create the cluster: `./run.sh install`
2. Cleanup the clusters: `./run.sh clean`


Running from CLI:

```sh
$./run.sh install
```

## Workload variables

The run.sh script can be tweaked with the following environment variables

| Variable                | Description              | Default |
|-------------------------|--------------------------|---------|
|**AZ_LOCATION**| Azure Datacenter | Central US|
|**AZ_CLUSTERNAME**| Name of ARO Cluster | - |
|**AZ_RESOURCEGROUP**| Name of Resource Group | Defaults to AZ_CLUSTERNAME-rg |
|**AZ_USERNAME**| Azure login Username |-|
|**AZ_PASSWORD**| Azure login password |-|
|**AZ_SUBSCRIPTION_ID** | Azure Subscription ID |-|
|**PULL_SECRET** | Pull secret required for Openshift Install | https://console.redhat.com/openshift/install/pull-secret |
