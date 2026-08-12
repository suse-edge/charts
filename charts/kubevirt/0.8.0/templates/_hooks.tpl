{{/* Hook annotations */}}
{{- define "kubevirt.hook.annotations" -}}
  annotations:
    "helm.sh/hook": {{ .hookType }}
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    "helm.sh/hook-weight": {{ .hookWeight | quote }}
{{- end -}}

{{/* Namespace modifying hook annotations */}}
{{- define "kubevirt.namespaceHook.annotations" -}}
{{ template "kubevirt.hook.annotations" merge (dict "hookType" "pre-install") . }}
{{- end -}}

{{/* CRD upgrading hook annotations */}}
{{- define "kubevirt.crdUpgradeHook.annotations" -}}
{{ template "kubevirt.hook.annotations" merge (dict "hookType" "pre-upgrade") . }}
{{- end -}}

{{/* Custom resource uninstalling hook annotations */}}
{{- define "kubevirt.crUninstallHook.annotations" -}}
{{ template "kubevirt.hook.annotations" merge (dict "hookType" "pre-delete") . }}
{{- end -}}

{{/* CRD uninstalling hook annotations */}}
{{- define "kubevirt.crdUninstallHook.annotations" -}}
{{ template "kubevirt.hook.annotations" merge (dict "hookType" "post-delete") . }}
{{- end -}}

{{/* Namespace modifying hook name */}}
{{- define "kubevirt.namespaceHook.name" -}}
{{ include "kubevirt.fullname" . }}-namespace-modify
{{- end }}

{{/* CRD upgrading hook name */}}
{{- define "kubevirt.crdUpgradeHook.name" -}}
{{ include "kubevirt.fullname" . }}-crd-upgrade
{{- end }}

{{/* Custom resource uninstalling hook name */}}
{{- define "kubevirt.crUninstallHook.name" -}}
{{ include "kubevirt.fullname" . }}-uninstall
{{- end }}

{{/* CRD uninstalling hook name */}}
{{- define "kubevirt.crdUninstallHook.name" -}}
{{ include "kubevirt.fullname" . }}-crd-uninstall
{{- end }}
