function pod-check::deis {
  log-info "Adding deis helm repo..."
  helm repo add deis https://github.com/deis/charts.git || true
  log-info "Update the charts!"
  helm up
  log-info "Fetching deis/${WORKFLOW_CHART}"
  helm fetch "deis/${WORKFLOW_CHART}"
  log-info "Installing chart ${WORKFLOW_CHART}"
  helm install -g -x manifests "${WORKFLOW_CHART}"
  log-info "Running kubectl describe pods and piping the output to ${DEIS_PODS}"
  kubectl describe pods --namespace=deis > ${DEIS_PODS}
}

function pod-check::other {
  helm install $1
}

function pod-check::arg {
  if [[ "$1" == "" || "$2" == "" ]]; then
    echo "Please follow the syntax: rerun chartmate:install <chart-name> <namespace>"
    exit
  fi
}

function pod-check::status {
  echo "running pod status check -----------"
  local i
  for i in $(kubectl get pods --namespace=$1 | awk 'NR > 1 {print $1}'); do
     while [ $(kubectl --namespace=$2 get pods $i -o json | jq -r ".status.phase") != "Running" ]; do
       printf ""
     done
     echo "$i is up and running"
  done
  echo " All the pods are up and running"
}
