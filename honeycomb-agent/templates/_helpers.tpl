{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "honeycomb-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "_labelSelector" -}}
{{ range $k, $v := . -}}
,{{ $k }}={{ $v }}
{{- end -}}
{{- end -}}

{{- define "labelSelector" -}}
{{- $labelSelector := include "_labelSelector" . }}
{{- trimPrefix "," $labelSelector }}
{{- end -}}

{{- define "config-map-name" -}}
{{ .Chart.Name }}-config
{{- end }}

{{- define "service-account-name" -}}
{{ .Chart.Name }}
{{- end }}

{{- define "writekey-secret-name" -}}
{{ .Chart.Name }}-writekey
{{- end }}

{{- define "cluster-role-name" -}}
pod-observer
{{- end }}
