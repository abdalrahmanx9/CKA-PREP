#!/bin/bash
set -e

echo "Starting CNI validation..."

# -------------------------------------------------
# 1. A CNI that supports Network Policies must be installed
#    (Calico or Cilium are valid; plain flannel is NOT)
# -------------------------------------------------
echo "Checking for a CNI with NetworkPolicy support..."

if kubectl get ds -n kube-system 2>/dev/null | grep -q kube-flannel; then
  echo "FAIL: flannel is installed - it does NOT support Network Policies"
  exit 1
fi

CALICO_NS=$(kubectl get ds -A --no-headers 2>/dev/null | awk '$2=="calico-node"{print $1}' | head -1)
CILIUM_DS=$(kubectl get ds -n kube-system cilium --no-headers 2>/dev/null | wc -l)

if [ -n "$CALICO_NS" ]; then
  # -------------------------------------------------
  # 2. calico-node DaemonSet pods must be Ready
  # -------------------------------------------------
  echo "Checking calico-node DaemonSet..."
  READY=$(kubectl get ds -n "$CALICO_NS" calico-node -o jsonpath='{.status.numberReady}')
  DESIRED=$(kubectl get ds -n "$CALICO_NS" calico-node -o jsonpath='{.status.desiredNumberScheduled}')
  if [ -n "$READY" ] && [ "$READY" = "$DESIRED" ] && [ "$READY" -gt 0 ] 2>/dev/null; then
    echo "PASS: calico-node $READY/$DESIRED pods ready"
  else
    echo "FAIL: calico-node $READY/$DESIRED ready"
    echo "Hint: on Killercoda, cilium is already the CNI - calico conflicts with it."
    echo "Hint: if the pod CIDR differs, set CALICO_IPV4POOL_CIDR in calico.yaml before applying."
    kubectl get pods -n "$CALICO_NS"
    exit 1
  fi
elif [ "$CILIUM_DS" -gt 0 ] 2>/dev/null; then
  echo "PASS: cilium is installed (supports NetworkPolicies)"
  echo "NOTE: cilium came preinstalled on this playground - there was nothing to install here."
  echo "      Practice the actual install (calico) on a clean cluster without a CNI."
  kubectl -n kube-system get pods -l k8s-app=cilium | tail -n +2
else
  echo "FAIL: no NetworkPolicy-capable CNI found (calico or cilium)"
  exit 1
fi

# -------------------------------------------------
# 3. Pods must actually get IP addresses (CNI is functional)
# -------------------------------------------------
echo "Checking that pods receive IP addresses..."
IP=$(kubectl get pods -A -o jsonpath='{.items[0].status.podIP}')
if [ -n "$IP" ]; then
  echo "PASS: pods have IPs (e.g. $IP)"
else
  echo "FAIL: pods have no IP - CNI is not functional"
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
