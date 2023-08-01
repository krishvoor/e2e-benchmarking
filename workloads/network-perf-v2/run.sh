#!/usr/bin/env bash
set -x

source ./env.sh
source ../../utils/common.sh

# Function to install Netperf
install_netperf() {
    curl -sS -L "$NETPERF_URL" | tar -xz
}

# Function to create the required resources
create_resources() {
  oc create ns netperf
  oc create sa netperf -n netperf
  oc adm policy add-scc-to-user hostnetwork -z netperf -n netperf
}

# Function for cleanup actions
cleanup() {
  rm -rf  "$NETPERF_TAR"
}

main() {
  trap cleanup EXIT
  install_netperf
  create_resources

  # Assuming kubeconfig is set
  log "###############################################"
  log "Workload: $WORKLOAD"
  log "###############################################"

  if [[ $OPTIONS == "iperf" || $OPTIONS == "local" || $OPTIONS == "across" ]]; then
    timeout "$TEST_TIMEOUT" "./$NETPERF_DIR" --debug --metrics --all "$OPTIONS" --search "$ES_SERVER" --tcp-tolerance "$TOLERANCE" --clean=true
  elif; then
    timeout $TEST_TIMEOUT ./k8s-netperf --debug --metrics --all --config ${WORKLOAD} --search $ES_SERVER --tcp-tolerance ${TOLERANCE} --clean=true
  if

  # Add debugging info (will be captured in each execution output)
  echo "============ Debug Info ============"
  echo "k8s-netperf version" $NETPERF_VERSION
  oc get pods -n netperf -o wide
  oc get nodes -o wide
  oc get machineset -A

  log "Finished workload $0 $WORKLOAD, exit code ($?)"
  cat *.csv

  return $?
}