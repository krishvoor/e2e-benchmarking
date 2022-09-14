#!/usr/bin/env bash

## ARO input vars
export AZ_LOCATION=${AZ_LOCATION:-centralus}
export AZ_CLUSTERNAME=${AZ_CLUSTERNAME:-""}
export AZ_RESOURCEGROUP=${AZ_RESOURCEGROUP:-${AZ_CLUSTERNAME}-rg}

export AZ_USERNAME=${AZ_USERNAME:-""}
export AZ_PASSWORD=${AZ_PASSWORD:-""}
export AZ_SUBSCRIPTION_ID=${AZ_SUBSCRIPTION_ID:-" "}
export PULL_SECRET=${PULL_SECRET:-""}

# Indexing stats
export ENABLE_INDEX=${ENABLE_INDEX:-true}
export ES_SERVER=${ES_SERVER:-https://search-perfscale-dev-chmf5l4sh66lvxbnadi4bznl3a.us-west-2.es.amazonaws.com:443}
export ES_INDEX=${ES_INDEX:-ripsaw-kube-burner}
export THANOS_QUERIER_URL=${THANOS_QUERIER_URL:-http://thanos.apps.cluster.devcluster/api/v1/receive}
