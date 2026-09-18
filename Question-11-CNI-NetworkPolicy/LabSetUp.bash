#!/bin/bash
set -e

# Step 1: Remove any preinstalled CNI (cilium / flannel) so Calico can take over
kubectl -n kube-system delete ds cilium cilium-envoy cilium-node-init kube-flannel-ds --ignore-not-found
kubectl -n kube-system delete deploy cilium-operator --ignore-not-found
kubectl -n kube-system delete cm cilium-config --ignore-not-found
sudo rm -f /etc/cni/net.d/*cilium* /etc/cni/net.d/*flannel*
echo "CNI cleanup done on this node."
echo "NOTE: also run this on node01:  sudo rm -f /etc/cni/net.d/*cilium* /etc/cni/net.d/*flannel*"

# Step 2: Detect the cluster pod CIDR for the Calico IP pool
POD_CIDR=$(kubectl get nodes -o jsonpath='{.items[0].spec.podCIDR}')
[ -n "$POD_CIDR" ] || POD_CIDR="10.244.0.0/16"
echo "Using pod CIDR: $POD_CIDR"

# Step 3: Download calico.yaml and point the IP pool at the cluster pod CIDR
curl -sL https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml -o /root/calico.yaml
sed -i -e 's|# - name: CALICO_IPV4POOL_CIDR|- name: CALICO_IPV4POOL_CIDR|' \
       -e "s|#   value: \"192.168.0.0/16\"|  value: \"$POD_CIDR\"|" /root/calico.yaml
grep -A1 'name: CALICO_IPV4POOL_CIDR' /root/calico.yaml | grep -q "$POD_CIDR" \
  || { echo "FAIL: could not set CALICO_IPV4POOL_CIDR in /root/calico.yaml"; exit 1; }
echo "Manifest ready at /root/calico.yaml (IP pool set to $POD_CIDR)"

echo
echo "Now solve the question: install the CNI from the manifest, then run ./run.sh 11 check"
