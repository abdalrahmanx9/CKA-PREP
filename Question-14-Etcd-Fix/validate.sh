#!/bin/bash
set -e

MANIFEST=/etc/kubernetes/manifests/kube-apiserver.yaml

echo "Starting Etcd-Fix validation..."

# -------------------------------------------------
# 1. etcd-servers must use the client port 2379 (not peer port 2380)
# -------------------------------------------------
echo "Checking kube-apiserver etcd configuration..."
ETCD_LINE=$(sudo grep 'etcd-servers' "$MANIFEST" || true)
if echo "$ETCD_LINE" | grep -q ':2379' && ! echo "$ETCD_LINE" | grep -q ':2380'; then
  echo "PASS: etcd-servers uses client port 2379 ($ETCD_LINE)"
else
  echo "FAIL: etcd-servers is still misconfigured (must use 2379, not 2380):"
  echo "  $ETCD_LINE"
  exit 1
fi

# -------------------------------------------------
# 2. API server must be reachable again
# -------------------------------------------------
echo "Checking API server responsiveness..."
if kubectl get nodes >/dev/null 2>&1; then
  echo "PASS: kubectl works - API server is up"
else
  echo "FAIL: API server is unreachable (kubectl get nodes failed)"
  exit 1
fi

# -------------------------------------------------
# 3. kube-apiserver pod must be Running
# -------------------------------------------------
echo "Checking kube-apiserver pod..."
PHASE=$(kubectl -n kube-system get pods -l component=kube-apiserver -o jsonpath='{.items[0].status.phase}')
if [ "$PHASE" = "Running" ]; then
  echo "PASS: kube-apiserver pod is Running"
else
  echo "FAIL: kube-apiserver pod phase is '$PHASE'"
  exit 1
fi

# -------------------------------------------------
# 4. All nodes must be Ready
# -------------------------------------------------
echo "Checking node status..."
NOT_READY=$(kubectl get nodes --no-headers | grep -vc ' Ready' || true)
if [ "$NOT_READY" = "0" ]; then
  echo "PASS: all nodes are Ready"
else
  echo "FAIL: $NOT_READY node(s) are not Ready:"
  kubectl get nodes
  exit 1
fi

echo
echo "SUCCESS: etcd configuration is fixed and the cluster is healthy"
