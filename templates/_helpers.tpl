{{/*
Default always defined top-level variables for helm charts
*/}}
{{- define "clustergroup.app.globalvalues.helmparameters" -}}
- name: global.repoURL
  value: {{ $.Values.global.repoURL }}
- name: global.originURL
  value: {{ $.Values.global.originURL }}
- name: global.targetRevision
  value: {{ $.Values.global.targetRevision }}
- name: global.namespace
  value: $ARGOCD_APP_NAMESPACE
- name: global.pattern
  value: {{ $.Values.global.pattern }}
- name: global.clusterDomain
  value: {{ $.Values.global.clusterDomain }}
- name: global.clusterVersion
  value: "{{ $.Values.global.clusterVersion }}"
- name: global.clusterPlatform
  value: "{{ $.Values.global.clusterPlatform }}"
- name: global.hubClusterDomain
  value: {{ $.Values.global.hubClusterDomain }}
- name: global.multiSourceSupport
  value: {{ $.Values.global.multiSourceSupport | quote }}
- name: global.multiSourceRepoUrl
  value: {{ $.Values.global.multiSourceRepoUrl }}
- name: global.multiSourceTargetRevision
  value: {{ $.Values.global.multiSourceTargetRevision }}
- name: global.localClusterDomain
  value: {{ coalesce $.Values.global.localClusterDomain $.Values.global.hubClusterDomain }}
- name: global.privateRepo
  value: {{ $.Values.global.privateRepo | quote }}
- name: global.experimentalCapabilities
  value: {{ $.Values.global.experimentalCapabilities | default "" }}
{{- end }} {{/* clustergroup.globalvaluesparameters */}}


{{/*
Default always defined valueFiles to be included in Applications
*/}}
{{- define "clustergroup.app.globalvalues.valuefiles" -}}
- "/values-global.yaml"
- "/values-{{ $.Values.clusterGroup.name }}.yaml"
{{- if $.Values.global.clusterPlatform }}
- "/values-{{ $.Values.global.clusterPlatform }}.yaml"
  {{- if $.Values.global.clusterVersion }}
- "/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.global.clusterVersion }}.yaml"
  {{- end }}
- "/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.clusterVersion }}
- "/values-{{ $.Values.global.clusterVersion }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.extraValueFiles }}
{{- range $.Values.global.extraValueFiles }}
- {{ . | quote }}
{{- end }} {{/* range $.Values.global.extraValueFiles */}}
{{- end }} {{/* if $.Values.global.extraValueFiles */}}
{{- end }} {{/* clustergroup.app.globalvalues.valuefiles */}}

{{/*
Default always defined valueFiles to be included in Applications but with a prefix called $patternref
*/}}
{{- define "clustergroup.app.globalvalues.prefixedvaluefiles" -}}
- "$patternref/values-global.yaml"
- "$patternref/values-{{ $.Values.clusterGroup.name }}.yaml"
{{- if $.Values.global.clusterPlatform }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}.yaml"
  {{- if $.Values.global.clusterVersion }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.global.clusterVersion }}.yaml"
  {{- end }}
- "$patternref/values-{{ $.Values.global.clusterPlatform }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.clusterVersion }}
- "$patternref/values-{{ $.Values.global.clusterVersion }}-{{ $.Values.clusterGroup.name }}.yaml"
{{- end }}
{{- if $.Values.global.extraValueFiles }}
{{- range $.Values.global.extraValueFiles }}
- "$patternref/{{ . }}"
{{- end }} {{/* range $.Values.global.extraValueFiles */}}
{{- end }} {{/* if $.Values.global.extraValueFiles */}}
{{- end }} {{/* clustergroup.app.globalvalues.prefixedvaluefiles */}}

{{/*
Helper function to generate AppProject from a map object
Called from common/clustergroup/templates/plumbing/projects.yaml
*/}}
{{- define "clustergroup.template.plumbing.projects.map" -}}
{{- $projects := index . 0 }}
{{- $namespace := index . 1 }}
{{- $enabled := index . 2 }}
{{- range $k, $v := $projects}}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ $k }}
{{- if (eq $enabled "plumbing") }}
  namespace: openshift-gitops
{{- else }}
  namespace: {{ $namespace }}
{{- end }}
spec:
  description: "Pattern {{ . }}"
  destinations:
  - namespace: '*'
    server: '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  sourceRepos:
  - '*'
status: {}
---
{{- end }}
{{- end }}

{{/*
  Helper function to generate AppProject from a list object.
  Called from common/clustergroup/templates/plumbing/projects.yaml
*/}}
{{- define "clustergroup.template.plumbing.projects.list" -}}
{{- $projects := index . 0 }}
{{- $namespace := index . 1 }}
{{- $enabled := index . 2 }}
{{- range $projects}}
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: {{ . }}
{{- if (eq $enabled "plumbing") }}
  namespace: openshift-gitops
{{- else }}
  namespace: {{ $namespace }}
{{- end }}
spec:
  description: "Pattern {{ . }}"
  destinations:
  - namespace: '*'
    server: '*'
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  sourceRepos:
  - '*'
status: {}
{{- end }}
{{- end }}

{{/*
  Helper function to generate Namespaces from a map object.
  Arguments passed as a list object are:
  0 - The namespace hash keys
  1 - Pattern name from .Values.global.pattern
  2 - Cluster group name from .Values.clusterGroup.name
  Called from common/clustergroup/templates/core/namespaces.yaml
*/}}
{{- define "clustergroup.template.core.namespaces.map" -}}
{{- $ns := index . 0 }}
{{- $patternName := index . 1 }}
{{- $clusterGroupName := index . 2 }}

{{- range $k, $v := $ns }}{{- /* We loop here even though the map has always just one key */}}
apiVersion: v1
kind: Namespace
metadata:
  name: {{ $k }}
  {{- if ne $v nil }}
  labels:
    argocd.argoproj.io/managed-by: {{ $patternName }}-{{ $clusterGroupName }}
    {{- if $v.labels }}
    {{- range $key, $value := $v.labels }} {{- /* We loop here even though the map has always just one key */}}
    {{ $key }}: {{ $value | default "" | quote }}
    {{- end }}
    {{- end }}
  {{- if $v.annotations }}
  annotations:
    {{- range $key, $value := $v.annotations }} {{- /* We loop through the map to get key/value pairs */}}
    {{ $key }}: {{ $value | default "" | quote }}
    {{- end }}
  {{- end }}{{- /* if $v.annotations */}}
  {{- end }}
spec:
---
{{- end }}{{- /* range $k, $v := $ns */}}
{{- end }}

{{- /*
  Helper function to generate OperatorGroup from a map object.
  Arguments passed as a list object are:
  0 - The namespace hash keys
  1 - The operatorExcludes section from .Values.clusterGroup.operatorgroupExcludes
  Called from common/clustergroup/templates/core/operatorgroup.yaml
*/ -}}
{{- define "clustergroup.template.core.operatorgroup.map" -}}
{{- $ns := index . 0 }}
{{- $operatorgroupExcludes := index . 1 }}
{{- if or (empty $operatorgroupExcludes) (not (has . $operatorgroupExcludes)) }}
  {{- range $k, $v := $ns }}{{- /* We loop here even though the map has always just one key */}}
  {{- if $v }}
    {{- if or $v.operatorGroup (not (hasKey $v "operatorGroup")) }}{{- /* Checks if the user sets operatorGroup: false */}}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: {{ $k }}-operator-group
  namespace: {{ $k }}
      {{- if (hasKey $v "targetNamespaces") }}
        {{- if $v.targetNamespaces }}
          {{- if (len $v.targetNamespaces) }}
spec:
  targetNamespaces:
            {{- range $v.targetNamespaces }}{{- /* We loop through the list of tergetnamespaces */}}
  - {{ . }}
            {{- end }}{{- /* End range targetNamespaces */}}
          {{- end }}{{- /* End if (len $v.targetNamespaces) */}}
        {{- end }}{{- /* End $v.targetNamespaces */}}
      {{- else }}
spec:
  targetNamespaces:
  - {{ $k }}
      {{- end }}{{- /* End of if hasKey $v "targetNamespaces" */}}
    {{- end }}{{- /* End if $v.operatorGroup */}}
  {{- else }}{{- /* else if $v == nil  */}}
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: {{ $k }}-operator-group
  namespace: {{ $k }}
spec:
  targetNamespaces:
  - {{ $k }}
  {{- end }}{{- /* end if $v */}}
  {{- end }}{{- /* End range $k, $v = $ns */}}
{{- end }}{{- /* End of if operatorGroupExcludes */}}
{{- end }} {{- /* End define  "clustergroup.template.core.operatorgroup.map" */}}

{{/*
Create a safe, DNS-compliant namespace.

This template calculates the maximum allowed length for the namespace based on the other
parts of the final URL. If the original namespace string (pattern + cluster group name)
is too long, it truncates it and appends a short hash for uniqueness.
*/}}
{{- define "clustergroup.gitops.namespace" -}}

{{- $clusterGroupName := .Values.clusterGroup.name -}}
{{- $pattern := .Values.global.pattern -}}
{{- $fullNamespace := printf "%s-%s" $pattern $clusterGroupName -}}
{{- $urlPrefix := printf "%s-gitops-server-" $clusterGroupName -}}

{{- /*
Calculate the max allowed length for the namespace by subtracting the
prefix's length from the 63-character DNS label limit.
*/ -}}
{{- $maxNamespaceLength := sub 63 (len $urlPrefix) -}}

{{- if gt (len $fullNamespace) $maxNamespaceLength -}}
  {{- /* If the namespace is too long, truncate it and add an 8-char hash suffix */ -}}
  {{- $hash := $fullNamespace | sha256sum | trunc 8 -}}
  {{- /* Calculate space for the truncated part, leaving room for the hyphen and hash */ -}}
  {{- $truncLength := sub $maxNamespaceLength (len $hash) 1 -}}
  {{- printf "%s-%s" ($fullNamespace | trunc $truncLength) $hash -}}
{{- else -}}
  {{- /* If the namespace is already short enough, use it as is */ -}}
  {{- $fullNamespace -}}
{{- end -}}{{- /* End of if gt (len $fullNamespace) $maxNamespaceLength */}}
{{- end -}}{{- /* End define "clustergroup.gitops.namespace" */}}
