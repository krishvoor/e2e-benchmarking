#!/usr/bin/env bash
set -x

source ./common.sh

if [ $# -eq 0 ]; then
    echo "Missing Argument"
    echo "Run './run.sh install' to install ARO"
    echo "Run './run.sh clean' to cleanup already installed ARO"
    exit 1
fi

prep
if [[ "$1" == "clean" ]]; then
    printf "Running Cleanup Steps"
    setup
    cleanup
elif [[ "$1" == "install" ]]; then
    echo "Set start time of prom scrape"
    export START_TIME=$(date +"%s")
    setup
    install
    echo "Check Hosted cluster progress..$HOSTED_CLUSTER_NAME"
    postinstall
    if [[ $ENABLE_INDEX == "true" ]]; then
        echo "Set end time of prom scrape"
        export END_TIME=$(date +"%s")
        index_mgmt_cluster_stat
    fi

    ## To-Do
    echo "Download the kubeconfig file of the ARO clusters to local.."
    echo "##################"
    echo "##################"
else
    echo "Wrong Argument"
    echo "Run './run.sh install' to install ARO"
    echo "Run './run.sh clean' to cleanup already installed ARO"
    exit 1    
fi
