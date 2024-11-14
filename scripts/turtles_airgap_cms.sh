#!/bin/bash
set -eux

# Script to generate the ConfigMap resources described in 
# https://turtles.docs.rancher.com/getting-started/air-gapped-environment

CAPI_CORE_VERSION="${CAPI_CORE_VERSION:-"1.7.7"}"
CAPI_CAPM3_VERSION="${CAPI_CAPM3_VERSION:-"1.7.2"}"
CAPI_RKE2_VERSION="${CAPI_RKE2_VERSION:-"0.8.0"}"

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGE_CHARTS_DIR="../packages/rancher-turtles-airgap-resources/charts/templates"

# FIXME could use TMPDIR perhaps
CAPI_TMPDIR="${CAPI_TMPDIR:-/tmp/turtles_airgap_cms}"
mkdir -p ${CAPI_TMPDIR}
rm -f ${CAPI_TMPDIR}/*.yaml

# Core cluster-api components
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CAPI_CORE_VERSION}/core-components.yaml -o ${CAPI_TMPDIR}/core-components.yaml
curl -L https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CAPI_CORE_VERSION}/metadata.yaml -o ${CAPI_TMPDIR}/core-metadata.yaml

# CAPI core components are too large to fit into the CM/annotation
# https://turtles.docs.rancher.com/getting-started/air-gapped-environment#situation-when-manifests-do-not-fit-into-configmap
gzip -c  ${CAPI_TMPDIR}/core-components.yaml > ${CAPI_TMPDIR}/core-components.gz
kubectl create configmap v${CAPI_CORE_VERSION} --namespace=capi-system --from-file=components=${CAPI_TMPDIR}/core-components.gz --from-file=metadata=${CAPI_TMPDIR}/core-metadata.yaml --dry-run=client -o yaml > ${CAPI_TMPDIR}/airgap-cm-core.yaml
yq eval -i '.metadata.annotations += {"provider.cluster.x-k8s.io/compressed": "true"}'  ${CAPI_TMPDIR}/airgap-cm-core.yaml
yq eval -i '.metadata.labels += {"provider-components": "core"}' ${CAPI_TMPDIR}/airgap-cm-core.yaml
cat > ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-core.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    cluster.x-k8s.io/provider: cluster-api
    control-plane: controller-manager
  name: capi-system
---
EOF
cat ${CAPI_TMPDIR}/airgap-cm-core.yaml >> ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-core.yaml

# infrastructure-components (infrastructure-metal3)
curl -L https://github.com/metal3-io/cluster-api-provider-metal3/releases/download/v${CAPI_CAPM3_VERSION}/infrastructure-components.yaml -o ${CAPI_TMPDIR}/metal3-components.yaml
curl -L https://github.com/metal3-io/cluster-api-provider-metal3/releases/download/v${CAPI_CAPM3_VERSION}/metadata.yaml -o ${CAPI_TMPDIR}/metal3-metadata.yaml
kubectl create configmap v${CAPI_CAPM3_VERSION} --namespace=capm3-system --from-file=components=${CAPI_TMPDIR}/metal3-components.yaml --from-file=metadata=${CAPI_TMPDIR}/metal3-metadata.yaml --dry-run=client -o yaml > ${CAPI_TMPDIR}/airgap-cm-metal3.yaml
yq eval -i '.metadata.labels += {"provider-components": "metal3"}' ${CAPI_TMPDIR}/airgap-cm-metal3.yaml
cat > ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-metal3.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    cluster.x-k8s.io/provider: infrastructure-metal3
    pod-security.kubernetes.io/enforce: restricted
  name: capm3-system
---
EOF
cat ${CAPI_TMPDIR}/airgap-cm-metal3.yaml >> ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-metal3.yaml

# boostrap-components (boostrap-rke2)
curl -L https://github.com/rancher-sandbox/cluster-api-provider-rke2/releases/download/v${CAPI_RKE2_VERSION}/bootstrap-components.yaml -o ${CAPI_TMPDIR}/rke2-bootstrap-components.yaml
curl -L https://github.com/rancher-sandbox/cluster-api-provider-rke2/releases/download/v${CAPI_RKE2_VERSION}/metadata.yaml -o ${CAPI_TMPDIR}/rke2-bootstrap-metadata.yaml
kubectl create configmap v${CAPI_RKE2_VERSION} --namespace=rke2-bootstrap-system --from-file=components=${CAPI_TMPDIR}/rke2-bootstrap-components.yaml --from-file=metadata=${CAPI_TMPDIR}/rke2-bootstrap-metadata.yaml --dry-run=client -o yaml > ${CAPI_TMPDIR}/airgap-cm-rke2-bootstrap.yaml
yq eval -i '.metadata.labels += {"provider-components": "rke2-bootstrap"}' ${CAPI_TMPDIR}/airgap-cm-rke2-bootstrap.yaml
cat > ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-rke2-bootstrap.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    cluster.x-k8s.io/provider: bootstrap-rke2
    control-plane: controller-manager
  name: rke2-bootstrap-system
---
EOF
cat ${CAPI_TMPDIR}/airgap-cm-rke2-bootstrap.yaml >> ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-rke2-bootstrap.yaml 

# control-plane-components (control-plane-rke2)
curl -L https://github.com/rancher-sandbox/cluster-api-provider-rke2/releases/download/v${CAPI_RKE2_VERSION}/control-plane-components.yaml -o ${CAPI_TMPDIR}/rke2-control-plane-components.yaml
curl -L https://github.com/rancher-sandbox/cluster-api-provider-rke2/releases/download/v${CAPI_RKE2_VERSION}/metadata.yaml -o ${CAPI_TMPDIR}/rke2-control-plane-metadata.yaml
kubectl create configmap v${CAPI_RKE2_VERSION} --namespace=rke2-control-plane-system --from-file=components=${CAPI_TMPDIR}/rke2-control-plane-components.yaml --from-file=metadata=${CAPI_TMPDIR}/rke2-control-plane-metadata.yaml --dry-run=client -o yaml > ${CAPI_TMPDIR}/airgap-cm-rke2-control-plane.yaml
yq eval -i '.metadata.labels += {"provider-components": "rke2-control-plane"}' ${CAPI_TMPDIR}/airgap-cm-rke2-control-plane.yaml
cat > ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-rke2-control-plane.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  labels:
    cluster.x-k8s.io/provider: control-plane-rke2
    control-plane: controller-manager
  name: rke2-control-plane-system
---
EOF
cat ${CAPI_TMPDIR}/airgap-cm-rke2-control-plane.yaml >> ${SCRIPTDIR}/${PACKAGE_CHARTS_DIR}/airgap-cm-rke2-control-plane.yaml
