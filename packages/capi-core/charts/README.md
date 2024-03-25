# Development

The CRDS and other resources in the chart were generated from the upstream release e.g

```
wget https://github.com/kubernetes-sigs/cluster-api/releases/download/v1.6.0/core-components.yaml
```

This can be split into files e.g

```
csplit core-components.yaml '/^---$/' '{*}'
```

The files can then be separated e.g for `crds`

```
for f in xx*; do if yq .kind $f | grep -q CustomResourceDefinition; then echo $f && mv $f $(yq .metadata.name $f).yml; else echo "not $f"; fi; done
```

In the deployment there are some variables clusterctl replaces via envsubst - currently they are replaced with hard-coded values, but we could
add helm values in future if needed
