# Deploy Rancher Turtles in airgapped scenarios

To simplify deployment of the suse-edge rancher-turtles wrapper chart in airgapped scenarios
this chart deploys the corresponding ConfigMap resources, as described in the
[Rancher Turtles Documentation](https://turtles.docs.rancher.com/getting-started/air-gapped-environment)

In addition to installing the chart, it will be necessary to adjust the rancher-turtles chart values:

```
cluster-api-operator:
  cluster-api:
    core:
      fetchConfig:
        selector: "{\"matchLabels\": {\"provider-components\": \"core\"}}"
    rke2:
      bootstrap:
        fetchConfig:
          selector: "{\"matchLabels\": {\"provider-components\": \"rke2-bootstrap\"}}"
      controlPlane:
        fetchConfig:
          selector: "{\"matchLabels\": {\"provider-components\": \"rke2-control-plane\"}}"
    metal3:
      infrastructure:
        fetchConfig:
          selector: "{\"matchLabels\": {\"provider-components\": \"metal3\"}}"
```
