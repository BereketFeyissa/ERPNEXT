{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "erpnext.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "erpnext.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "erpnext.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "erpnext.labels" -}}
helm.sh/chart: {{ include "erpnext.chart" . }}
{{ include "erpnext.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "erpnext.selectorLabels" -}}
app.kubernetes.io/name: {{ include "erpnext.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "erpnext.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "erpnext.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create redis host name
*/}}
{{- define "redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Gets the mariadb host name
*/}}
{{- define "erpnext.mariadbHost" -}}
{{ .Values.mariadbHost }}
{{- end -}}

{{/*
Gets the redis socketio host name
*/}}
{{- define "erpnext.redisSocketIOHost" -}}
{{ .Values.redisSocketIOHost }}
{{- end -}}

{{/*
Gets the redis queue host name
*/}}
{{- define "erpnext.redisQueueHost" -}}
{{ .Values.redisQueueHost }}
{{- end -}}

{{/*
Gets the redis cache host name
*/}}
{{- define "erpnext.redisCacheHost" -}}
{{ .Values.redisCacheHost }}
{{- end -}}

{{/*
Bash snippet that prints the sites selected by jobs.migrate (mode/siteName/sites/sitesRegex), one per line.
Fails the render when the mode is unknown or the value it needs is empty.
*/}}
{{- define "erpnext.migrate.siteList" -}}
{{- if eq .Values.jobs.migrate.mode "single" -}}
echo {{ required "jobs.migrate.siteName is required when jobs.migrate.mode is \"single\"" .Values.jobs.migrate.siteName | quote }}
{{- else if eq .Values.jobs.migrate.mode "list" -}}
{{- if not .Values.jobs.migrate.sites }}{{ fail "jobs.migrate.sites must not be empty when jobs.migrate.mode is \"list\"" }}{{ end -}}
printf '%s\n'{{ range .Values.jobs.migrate.sites }} {{ . | quote }}{{ end }}
{{- else if not (has .Values.jobs.migrate.mode (list "all" "regex")) -}}
{{- fail (printf "jobs.migrate.mode must be one of single, all, regex, list (got %q)" .Values.jobs.migrate.mode) -}}
{{- else -}}
{{- if eq .Values.jobs.migrate.mode "regex" -}}
sites_regex={{ required "jobs.migrate.sitesRegex is required when jobs.migrate.mode is \"regex\"" .Values.jobs.migrate.sitesRegex | quote }}
{{ end -}}
for site_dir in sites/*; do
  if [ -d "$site_dir" ] && [ -f "$site_dir/site_config.json" ]; then
    site=$(basename "$site_dir")
    {{- if eq .Values.jobs.migrate.mode "regex" }}
    if [[ $site =~ $sites_regex ]]; then echo "$site"; fi
    {{- else }}
    echo "$site"
    {{- end }}
  fi
done
{{- end -}}
{{- end -}}
