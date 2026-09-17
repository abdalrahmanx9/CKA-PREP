#!/bin/bash
set -e

echo "Starting Resource-Allocation validation..."

# -------------------------------------------------
# 1. Deployment must be scaled back to 3 replicas
# -------------------------------------------------
echo "Checking replica count..."
READY=$(kubectl get deploy wordpress -o jsonpath='{.status.readyReplicas}')
if [ "$READY" = "3" ]; then
  echo "PASS: wordpress deployment has 3 ready replicas"
else
  echo "FAIL: expected 3 ready replicas, got '$READY' (did you scale it back up?)"
  exit 1
fi

# -------------------------------------------------
# 2. Main container must have requests and limits (cpu + memory)
# -------------------------------------------------
echo "Checking resources on the wordpress container..."
for JP in \
  '{.spec.template.spec.containers[0].resources.requests.cpu}' \
  '{.spec.template.spec.containers[0].resources.requests.memory}' \
  '{.spec.template.spec.containers[0].resources.limits.cpu}' \
  '{.spec.template.spec.containers[0].resources.limits.memory}'; do
  V=$(kubectl get deploy wordpress -o jsonpath="$JP")
  if [ -z "$V" ]; then
    echo "FAIL: missing $JP on the wordpress container"
    exit 1
  fi
done
echo "PASS: wordpress container has cpu/memory requests and limits"

# -------------------------------------------------
# 3. Init container must have requests and limits (cpu + memory)
# -------------------------------------------------
echo "Checking resources on the init-setup container..."
for JP in \
  '{.spec.template.spec.initContainers[0].resources.requests.cpu}' \
  '{.spec.template.spec.initContainers[0].resources.requests.memory}' \
  '{.spec.template.spec.initContainers[0].resources.limits.cpu}' \
  '{.spec.template.spec.initContainers[0].resources.limits.memory}'; do
  V=$(kubectl get deploy wordpress -o jsonpath="$JP")
  if [ -z "$V" ]; then
    echo "FAIL: missing $JP on the init-setup container"
    exit 1
  fi
done
echo "PASS: init-setup container has cpu/memory requests and limits"

# -------------------------------------------------
# 4. Init and main containers must use the SAME values
# -------------------------------------------------
echo "Checking that init and main containers use identical resources..."
MAIN=$(kubectl get deploy wordpress -o jsonpath='{.spec.template.spec.containers[0].resources}')
INIT=$(kubectl get deploy wordpress -o jsonpath='{.spec.template.spec.initContainers[0].resources}')
if [ "$MAIN" = "$INIT" ]; then
  echo "PASS: both containers use: $MAIN"
else
  echo "FAIL: resources differ between containers:"
  echo "  wordpress  : $MAIN"
  echo "  init-setup : $INIT"
  exit 1
fi

echo
echo "SUCCESS: resource allocation is valid"


