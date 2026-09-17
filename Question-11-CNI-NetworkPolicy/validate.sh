#!/bin/bash
set -e

echo "Starting CNI validation..."

# -------------------------------------------------
# 1. A CNI that supports Network Policies must be installed
#    (Calico = calico/tigera pods, NOT plain flannel)
# -------------------------------------------------
echo "Checking for a CNI with NetworkPolicy support..."

if kubectl get ds -n kube-system 2>/dev/null | grep -q kube-flannel; then
  echo "FAIL: flannel is installed - it does NOT support Network Policies"
  exit 1
fi

if kubectl get pods -n calico-system 2>/dev/null | grep -q calico-node; then
  echo "PASS: calico is installed"
else
  echo "FAIL: no calico pods found in calico-system (did you install a CNI?)"
  exit 1
fi

# -------------------------------------------------
# 2. calico-node DaemonSet pods must be Ready
# -------------------------------------------------
echo "Checking calico-node DaemonSet..."
READY=$(kubectl get ds -n calico-system calico-node -o jsonpath='{.status.numberReady}')
DESIRED=$(kubectl get ds -n calico-system calico-node -o jsonpath='{.status.desiredNumberScheduled}')
if [ -n "$READY" ] && [ "$READY" = "$DESIRED" ] && [ "$READY" -gt 0 ] 2>/dev/null; then
  echo "PASS: calico-node $READY/$DESIRED pods ready"
else
  echo "FAIL: calico-node $READY/$DESIRED ready"
  kubectl get pods -n calico-system
  exit 1
fi

# -------------------------------------------------
# 3. Pods must actually get IP addresses (CNI is functional)
# -------------------------------------------------
echo "Checking that pods receive IP addresses..."
IP=$(kubectl get pods -n calico-system -o jsonpath='{.items[0].status.podIP}')
if [ -n "$IP" ]; then
  echo "PASS: pods have IPs (e.g. $IP)"
else
  echo "FAIL: calico pods have no IP - CNI is not functional"
  exit 1
fi

# -------------------------------------------------
# 4. NetworkPolicy resource is accepted by the cluster
# -------------------------------------------------
echo "Checking NetworkPolicy support..."
cat <<EOF | kubectl apply -f - >/dev/null 2>&1 || { echo "FAIL: could not create a test NetworkPolicy"; exit 1; }
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-validate-test
  namespace: default
spec:
  podSelector:
    matchLabels:
      np-validate-test: "true"
EOF
kubectl delete netpol np-validate-test -n default >/dev/null 2>&1 || true
echo "PASS: NetworkPolicy created and deleted successfully"

echo
echo "SUCCESS: CNI is installed and supports Network Policies"
