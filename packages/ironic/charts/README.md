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

- tlsSource secrets

Ironic helm-chart values.yaml or overrides file
```
tls.cacert: <Custom root CA>
tls.key: <Custom tls key>
tls.crt: <Custom tls crt>
```
