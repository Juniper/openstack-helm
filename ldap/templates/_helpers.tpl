{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "splitdomain" -}}
{{- $name := index . 0 -}}
{{- $local := dict "first" true }}
{{- range $k, $v := splitList "." $name }}{{- if not $local.first -}},{{- end -}}dc={{- $v -}}{{- $_ := set $local "first" false -}}{{- end -}}
{{- end -}}
