## How to Enable TLS

Currently TLS is implemented only for ironic helm chart. 

In order to enable TLS, common options to be maintained in values.yaml or the override files

```
global.enable_tls: true
global.enable_ironic: true
ingress.tlsSource: self ( Valid Options: "self, letsEncrypt, secrets")
tls: ingress (Where to offload the TLS/SSL encryption – Valid Options: "ingress, ironic"
```

Additional options if 

- tlsSource letsEncrypt

### Pre-requistes

* Valid Domain registered in CloudFlare
* Valid CloudFlare API token available

metal3-demo environment extra_vars.yaml should have following uncommented
```
dns_provider: cloudflare
cloudflare:
  apiToken: "foo"
  proxied: false
```

Ironic helm-chart values.yaml or overrides file
```
global.dnsDomain: baremetal.management (Valid Domain Name registered in CloudFlare)
baremetaloperator.cloudflareApiToken: "foo" (Valid CloudFlare API Token for the domain registered)
```

- tlsSource secrets

Ironic helm-chart values.yaml or overrides file
```
tls.cacert: <Custom root CA>
tls.key: <Custom tls key>
tls.crt: <Custom tls crt>
```
