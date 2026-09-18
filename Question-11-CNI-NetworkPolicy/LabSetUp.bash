#!/bin/bash
set -e

# Step 1: Remove any preinstalled CNI (cilium / flannel) so Calico can take over
kubectl -n kube-system delete ds cilium cilium-envoy cilium-node-init kube-flannel-ds --ignore-not-found
kubectl -n kube-system delete deploy cilium-operator --ignore-not-found
kubectl -n kube-system delete cm cilium-config --ignore-not-found

# Step 2: Clean old CNI config files on ALL nodes (one-shot privileged cleanup DaemonSet)
cat <<EOF | kubectl apply -f - >/dev/null
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: cni-cleanup
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: cni-cleanup
  template:
    metadata:
      labels:
        app: cni-cleanup
    spec:
      hostNetwork: true
      tolerations:
      - operator: Exists
      containers:
      - name: cleanup
        image: busybox:stable
        command: ["sh", "-c", "rm -f /cni-net/*cilium* /cni-net/*flannel*; sleep 60"]
        securityContext:
          privileged: true
        volumeMounts:
        - name: cni-net
          mountPath: /cni-net
      volumes:
      - name: cni-net
        hostPath:
          path: /etc/cni/net.d
EOF

echo "Waiting for CNI cleanup to run on all nodes..."
for i in $(seq 1 24); do
  RUNNING=$(kubectl -n kube-system get pods -l app=cni-cleanup --no-headers 2>/dev/null | grep -c ' Running' || true)
  DESIRED=$(kubectl -n kube-system get ds cni-cleanup -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null)
  if [ -n "$DESIRED" ] && [ "$RUNNING" -ge "$DESIRED" ] 2>/dev/null; then break; fi
  sleep 5
done
sleep 5
kubectl -n kube-system delete ds cni-cleanup --ignore-not-found >/dev/null
echo "CNI config cleaned on all nodes."

# Step 3: Detect the cluster pod CIDR for the Calico IP pool
POD_CIDR=$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}')
[ -n "$POD_CIDR" ] || POD_CIDR="10.244.0.0/16"
echo "Using pod CIDR: $POD_CIDR"

# Step 4: Download calico.yaml and point the IP pool at the cluster pod CIDR
curl -sL https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml -o /root/calico.yaml
sed -i -e 's|# - name: CALICO_IPV4POOL_CIDR|- name: CALICO_IPV4POOL_CIDR|' \
       -e "s|#   value: \"192.168.0.0/16\"|  value: \"$POD_CIDR\"|" /root/calico.yaml
grep -A1 'name: CALICO_IPV4POOL_CIDR' /root/calico.yaml | grep -q "$POD_CIDR" \
  || { echo "FAIL: could not set CALICO_IPV4POOL_CIDR in /root/calico.yaml"; exit 1; }
echo "Manifest ready at /root/calico.yaml (IP pool set to $POD_CIDR)"

echo
echo "Now solve the question: install the CNI from the manifest, then run ./run.sh 11 check"
