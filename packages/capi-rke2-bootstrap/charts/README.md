# Development

The CRDS and other resources in the chart were generated from the upstream release e.g

```
wget https://github.com/rancher-sandbox/cluster-api-provider-rke2/releases/download/v0.2.6/bootstrap-components.yaml
```

This can be split into files e.g

```
csplit bootstrap-components.yaml '/^---$/' '{*}'
```

The files can then be separated e.g for `crds`

```
for f in xx*; do if yq .kind $f | grep -q CustomResourceDefinition; then echo $f && mv $f $(yq .metadata.name $f).yml; else echo "not crd $f"; fi; done
```

Other files can be renamed and concatenated as needed e.g

```
for f in xx*; do cat $f >> ../templates/$(yq '.kind' $f | tr 'A-Z' 'a-z').yaml; done
```

In the deployment there are some variables clusterctl replaces via envsubst - currently they are replaced with hard-coded values, but we could
add helm values in future if needed
