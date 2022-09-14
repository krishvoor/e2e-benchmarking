#!/usr/bin/env bash
set -x

source env.sh
TEMP_DIR=`mktemp -d`

prep(){
    if [[ -z $(az version) ]]; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        sudo dnf install -y https://packages.microsoft.com/config/rhel/8/packages-microsoft-prod.rpm
        sudo dnf install azure-cli -y
        sudo dnf remove packages-microsoft-prod -y
    fi
    if [[ -z $(oc version --client) ]]; then
        curl -L https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o openshift-client-linux.tar.gz
        tar xzf openshift-client-linux.tar.gz
        sudo mv oc kubectl ${TEMP_DIR}/bin/
        export PATH=${TEMP_DIR}/bin/:$PATH
    fi

}

setup(){
    echo "Login via Azure-cli..."
    # This will not work with accounts having two-factor authentication enabled
    az login --username ${AZ_USERNAME} --password ${AZ_PASSWORD}
    az account show
    oc version --client

    echo "Check the current Subscription Quota..."
    az vm list-usage -l ${AZ_LOCATION} --query "[?contains(name.value, 'standardDSv3Family')]" -o table
    
    echo "Register the resources providers"
    az account set --subscription ${AZ_SUBSCRIPTION_ID}
    az provider register -n Microsoft.RedHatOpenShift --wait
    az provider register -n Microsoft.Compute --wait
    az provider register -n Microsoft.Storage --wait
    az provider register -n Microsoft.Authorization --wait
}

install(){
    echo "Creating a virtual network..."
    az network vnet create --resource-group ${AZ_RESOURCEGROUP} --name ${AZ_CLUSTERNAME}-vnet --address-prefixes 10.0.0.0/22

    echo "Creating an empty subnet for the master nodes..."
    az network vnet subnet create --resource-group ${AZ_RESOURCEGROUP} --vnet-name ${AZ_CLUSTERNAME}-vnet --name ${AZ_CLUSTERNAME}-master-subnet --address-prefixes 10.0.0.0/23 --service-endpoints Microsoft.ContainerRegistry

    echo "Creating an empty subnet for the worker nodes..."
    az network vnet subnet create --resource-group ${AZ_RESOURCEGROUP} --vnet-name ${AZ_CLUSTERNAME}-vnet --name ${AZ_CLUSTERNAME}-worker-subnet --address-prefixes 10.0.2.0/23 --service-endpoints Microsoft.ContainerRegistry

    echo "Disable subnet private endpoint policies..."
    az network vnet subnet update --name ${AZ_CLUSTERNAME}-master-subnet --resource-group ${AZ_RESOURCEGROUP} --vnet-name ${AZ_CLUSTERNAME}-vnet --disable-private-link-service-network-policies true

    echo "Creating the cluster..."
    az aro create cluster --resource-group ${AZ_RESOURCEGROUP} --name ${AZ_CLUSTERNAME} --vnet ${AZ_CLUSTERNAME}-vnet --master-subnet ${AZ_CLUSTERNAME}-master-subnet --worker-subnet ${AZ_CLUSTERNAME}-worker-subnet --pull-secret @pull-secret.txt
}

postinstall(){
    echo "Retrieving ${AZ_CLUSTERNAME}'s kubeadmin credentials..."
    az aro list-credentials --name ${AZ_CLUSTERNAME} --resource-group ${AZ_RESOURCEGROUP}

    echo "Retrieving ${AZ_CLUSTERNAME}'s Web Console URL..."
    az aro show --name ${AZ_CLUSTERNAME} --resource-group ${AZ_RESOURCEGROUP} --query "consoleProfile.url" -o tsv

    echo "Retrieving ${AZ_CLUSTERNAME}'s API Server's Address..."
    az aro show --name ${AZ_CLUSTERNAME} --resource-group ${AZ_RESOURCEGROUP} --query "apiserverProfile.url" -o tsv
}


cleanup(){
    echo "Cleanup ${AZ_CLUSTERNAME} ARO Cluster..."
    az aro delete --resource-group ${AZ_RESOURCEGROUP} --name ${AZ_CLUSTERNAME} --yes
}

index_mgmt_cluster_stat(){
}