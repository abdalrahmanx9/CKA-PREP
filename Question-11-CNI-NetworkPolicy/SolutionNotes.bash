# NOTE: Killercoda's CKA playground already ships cilium (NetworkPolicy capable) - ./run.sh 11 check passes as-is there.
# On a cluster WITHOUT a CNI, install Calico as below.
# If calico-node pods stay not-ready, set CALICO_IPV4POOL_CIDR to your cluster pod CIDR in calico.yaml first.

# Step 1
# The key defining factor in the criteria is network policies, Flannel doesn't support network policies,
# Calico does. We can confirm this by running the following
curl -sL https://github.com/flannel-io/flannel/releases/download/v0.26.1/kube-flannel.yml | grep network
# We see nothing relating to networks in the flannel yaml, now lets try Calico
curl -sL https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml
# We see several references to networks and network policies, therefore we know Calico is the choice

# Step 2
# We need to apply the Calico file
k create -f https://raw.githubusercontent.com/projectcalico/calico/v3.28.2/manifests/calico.yaml

# Step 3 check everything has been deployed
k get pods -n kube-system | grep calico
# We should see pods, deployments and replicasets


