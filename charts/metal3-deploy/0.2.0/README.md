# Prerequisites
There are two dependencies that are not managed through the metal3 chart because are related to applications that have a cluster-wide scope: `cert-manager` and a LoadBalancer Service provider such as `metallb` or `kube-vip`.

## Cert Manager
In order to successfully deploy metal3 the cluster must have already installed the `cert-manager`.

You can install it through `helm` with:
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.11.1 \
  --set installCRDs=true
```
, or via `kubectl` with:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.1/cert-manager.yaml
```

## MetalLB (Optional)
To configure Ironic to use static IP instead of PowerDNS and External DNS, the following things should be done:

1. If K3s is used as Kubernetes distribution, then it should be started with `--disable=servicelb` flag. Ref https://metallb.universe.tf/configuration/k3s/
2. Find 1 free IP address in the network.
3. Install `MetalLB` through `helm` with:

```bash
helm repo add suse-edge https://suse-edge.github.io/charts
helm install \
  metallb suse-edge/metallb \
  --namespace metallb-system \
  --create-namespace
```

4. Provide the IP pool configuration with:

```bash
cat <<-EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: ironic-ip-pool
  namespace: metallb-system
spec:
  addresses:
  - <STATIC_IRONIC_IP>/32
  serviceAllocation:
    priority: 100
    serviceSelectors:
    - matchExpressions:
      - {key: app.kubernetes.io/name, operator: In, values: [metal3-ironic]}
EOF

cat <<-EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: ironic-ip-pool-l2-adv
  namespace: metallb-system
spec:
  ipAddressPools:
  - ironic-ip-pool
EOF
```

5. Change the following values in the `metal3-deploy/0.1.0/values.yaml` file:

```
global:
  enable_external_dns: false
  enable_pdns: false
  enable_metallb: true
  ironicIP: "<STATIC_IRONIC_IP>"
  ingress:
    enabled: false

metal3-ironic:
  service:
    type: LoadBalancer 
```

# Install

```bash
helm install metal3 . -n metal3-system --create-namespace
```

# How to upgrade the chart
1. Run `helm dependency update .` in this chart to download/update the dependent charts.

2. Identify the appropriate subchart values settings and create an appropriate override values YAML file.
   * Ensure that the relevant ironic and baremetal-operator settings match.
   * Ensure that the relevant powerdns and external-dns settings match.
   * Ensure that the same DNS domain is configured for all relevant services.

3. Install the chart using a command like the following:

```console
$ helm upgrade heavy-metal . --namespace metal-cubed --create-namespace --install --values ~/overrides.yaml
```
