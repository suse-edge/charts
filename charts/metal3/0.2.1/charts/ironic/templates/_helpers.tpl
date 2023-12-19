{{/*
Expand the name of the chart.
*/}}
{{- define "ironic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ironic.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "ironic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ironic.labels" -}}
helm.sh/chart: {{ include "ironic.chart" . }}
{{ include "ironic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ironic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ironic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "ironic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "ironic.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Shared directory volumeMount
*/}}
{{- define "ironic.sharedVolumeMount" -}}
- mountPath: /shared
  name: ironic-data-volume
{{- end }}


{{/*
Get certificate volumeMounts
*/}}
{{- define "ironic.certVolumeMounts" -}}
- mountPath: /certs/ironic/tls.crt
  name: ironic-certs
  subPath: tls.crt
- mountPath: /certs/ironic/tls.key
  name: ironic-certs
  subPath: tls.key
- mountPath: /certs/ironic-inspector/tls.crt
  name: ironic-insp-certs
  subPath: tls.crt
- mountPath: /certs/ironic-inspector/tls.key
  name: ironic-insp-certs
  subPath: tls.key
- mountPath: /certs/ca/ironic/tls.crt
  name: ironic-cacerts
  subPath: tls.crt
- mountPath: /certs/ca/ironic-inspector/tls.crt
  name: ironic-insp-cacerts
  subPath: tls.crt
{{- end }}


{{/*
Get secret volumeMounts
*/}}
{{- define "ironic.secretVolMounts" -}}
- name: ironic-certs
  mountPath: "/certs/ironic"
  readOnly: true
- name: ironic-insp-certs
  mountPath: "/certs/ironic-inspector"
  readOnly: true
- name: vmedia-certs
  mountPath: "/certs/vmedia"
  readOnly: true
- name: vmedia-ca-certs
  mountPath: "/certs/ca/vmedia"
  readOnly: true
{{- end }}

{{/*
Get cacert volumeMounts
*/}}
{{- define "ironic.cacertVolumeMounts" -}}
- mountPath: /etc/pki/trust/anchors/ca.crt
  name: ironic-trustca
  subPath: tls.cacert
- mountPath: /shared/html/tstcerts/ca.crt
  name: ironicipa-trustca
  subPath: tls.cacert
{{- end }}

{{/*
Get trust cert volumeMounts
*/}}
{{- define "ironic.trustVolMounts" -}}
- name: ironic-trustcerts
  mountPath: "/etc/pki/trust/anchors"
  readOnly: true
- name: ironicipa-trustcerts
  mountPath: "/shared/html/tstcerts"
  readOnly: true
{{- end }}

{{/*
Get letsEncrypt volumeMounts
*/}}
{{- define "ironic.letsEncryptVolMounts" -}}
- mountPath: /etc/pki/trust/anchors/ca.crt
  name: ironic-le-trustca
  subPath: tls.lecacert
- mountPath: /shared/html/tstcerts/ca.crt
  name: ironicipa-le-trustca
  subPath: tls.lecacert
{{- end }}


{{/*
Get ironic volumes
*/}}
{{- define "ironic.volumes" -}}
{{- if .Values.global.enable_ironic }}
- name: ironic-data-volume
  persistentVolumeClaim:
    claimName: ironic-shared-volume
{{- end }}
{{- if .Values.global.enable_ironic }}
{{- if .Values.global.enable_tls }}
{{- if eq .Values.ingress.tlsSource "secrets" }}
- name: ironic-trustca
  configMap:
    defaultMode: 493
    name: ironic-certs
- name: ironicipa-trustca
  configMap:
    defaultMode: 493
    name: ironic-certs    
{{- end }}
{{- if (eq .Values.ingress.tlsSource "self") }}
- name: ironic-trustcerts
  secret:
    secretName: ironic-cacert
- name: ironicipa-trustcerts
  secret:
    secretName: ironic-cacert    
{{- end }}
{{- if (eq .Values.ingress.tlsSource "letsEncrypt") }}
- name: ironic-le-trustca
  configMap:
    defaultMode: 493
    name: ironic-certs
- name: ironicipa-le-trustca
  configMap:
    defaultMode: 493
    name: ironic-certs
{{- end }}    
{{- end }}
{{- if and ($.Values.global.enable_tls) (eq .Values.ingress.tlsSource "secrets") (eq .Values.tls "ironic") }}
- name: ironic-certs
  configMap:
    defaultMode: 493
    name: ironic-certs
- name: ironic-insp-certs
  configMap:
    defaultMode: 493
    name: ironic-certs
- name: ironic-cacerts
  configMap:
    defaultMode: 493
    name: ironic-certs
- name: ironic-insp-cacerts
  configMap:
    defaultMode: 493
    name: ironic-certs
{{- end }}
{{- if and ($.Values.global.enable_tls) (or (eq .Values.ingress.tlsSource "self") (eq .Values.ingress.tlsSource "letsEncrypt")) (eq .Values.tls "ironic") }}
- name: ironic-certs
  secret:
    secretName: ironic-cacert
- name: ironic-insp-certs
  secret:
    secretName: ironic-cacert
- name: vmedia-certs
  secret:
    secretName: ironic-cacert    
- name: vmedia-ca-certs
  secret:
    secretName: ironic-cacert    
{{- end }}
{{- end }}
{{- end }}

{{/*
Get ironic tls volumeMounts
*/}}
{{- define "ironic.tlsVolumeMounts" -}}
{{- if (eq .Values.ingress.tlsSource "secrets") }}
  {{- include "ironic.cacertVolumeMounts" . }}
{{- end }}
{{- if (eq .Values.ingress.tlsSource "self") }}
  {{- include "ironic.trustVolMounts" . }}
{{- end }}
{{- if (eq .Values.ingress.tlsSource "letsEncrypt") }}
  {{- include "ironic.letsEncryptVolMounts" . }}
{{- end }}
{{- end }}
{{- if and ($.Values.global.enable_tls) (eq .Values.tls "ironic") }}
{{- if (eq .Values.ingress.tlsSource "secrets") }}
  {{- include "ironic.certVolumeMounts" . }}
{{- end }}
{{- if or (eq .Values.ingress.tlsSource "self") (eq .Values.ingress.tlsSource "letsEncrypt") }}
  {{- include "ironic.secretVolMounts" . }}
{{- end }}
{{- end }}