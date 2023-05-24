# How to use this chart
1. Run `helm dependency update .` in this chart to download/update the dependent charts.

2. Identify the appropriate subchart values settings and create an appropriate override values YAML file.
   * Ensure that the relevant ironic and baremetal-operator settings match.
   * Ensure that the relevant powerdns and external-dns settings match.
   * Ensure that the same DNS domain is configured for all relevant services.

3. Install the chart using a command like the following:

```console
$ helm upgrade heavy-metal . --namespace metal-cubed --create-namespace --install --values ~/overrides.yaml
```
