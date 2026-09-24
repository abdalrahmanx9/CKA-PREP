# Step one
# We want the ConfigMap to only support TLSv1.3 AND be immutable
# Gotcha: an existing ConfigMap can NOT be edited to become immutable - you must recreate it
k get cm -n nginx-static nginx-config -o yaml > cm.yaml
vi cm.yaml
# - remove TLSv1.2 from ssl_protocols
# - add: immutable: true  (in the metadata section)
k delete cm -n nginx-static nginx-config
k apply -f cm.yaml

# Step 2
# We need to get the IP of the service
k get svc -n nginx-static
# We need to add this IP with the host name to /etc/hosts
sudo echo 'x.x.x.x ckaquestion.k8s.local' >> /etc/hosts
# Check the hosts file has been updated the IP and host should be added to the bottom of the file
sudo cat /etc/hosts

# Step 3
# If we run the check commands now we see v1.2 is still working, this is because we need to restart the deployment to use the new CM config
k rollout restart -n nginx-static deployment nginx-static
# Test the commands again and the v1.2 should no longer work