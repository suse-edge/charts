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

## How to Enable Provisioning Network

By default PXE boot functionality is disabled, so deployments via e.g redfish-virtualmedia may
be performed without any dedicated provisioning network.

For PXE boot a dedicated network is required, in this case we run a dnsmasq instance to provide
DHCP and require a dedicated NIC for connectivity to the provisioning network on each host.

To enable this mode you must provide the following additional configuration (note the values are
examples and will depend on your environment):

```
global:
  enable_dnsmasq: true
  enable_pxe_boot: true
  dnsmasqDefaultRouter: 192.168.21.254
  dnsmasqDNSServer: 192.168.20.5
  dhcpRange: 192.168.20.20,192.168.20.80
  provisioningInterface: ens4
  provisioningIP: 192.168.20.5
```

Note that these values *must not* conflict with your controlplane or other networks otherwise unexpected
behavior is likely - a dedicated physical network is required in this configuration.
