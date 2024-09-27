{{/*
Expand the name of the chart.
*/}}
{{- define "upgrade-controller.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "upgrade-controller.fullname" -}}
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
{{- define "upgrade-controller.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "upgrade-controller.labels" -}}
helm.sh/chart: {{ include "upgrade-controller.chart" . }}
{{ include "upgrade-controller.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "upgrade-controller.selectorLabels" -}}
app.kubernetes.io/name: {{ include "upgrade-controller.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "upgrade-controller.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "upgrade-controller.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Webhook service name
*/}}
{{- define "upgrade-controller.webhookServiceName" -}}
{{ .Release.Name }}-webhook
{{- end }}

{{/*
Certificate issuer name
*/}}
{{- define "upgrade-controller.certificateIssuer" -}}
{{ .Release.Name }}-self-signed-issuer
{{- end }}

{{/*
Certificate name
*/}}
{{- define "upgrade-controller.certificate" -}}
{{ .Release.Name }}-serving-cert
{{- end }}
