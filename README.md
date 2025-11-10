# clustergroup

![Version: 0.9.37](https://img.shields.io/badge/Version-0.9.37-informational?style=flat-square)

A Helm chart to create per-clustergroup ArgoCD applications and any required namespaces or subscriptions.

This chart is used to set up the basic building blocks in [Validated Patterns](https://validatedpatterns.io)

### Notable changes

* v0.9.37: Use global.patternDelete value set by patterns operator when patterns are deleted
* v0.9.32: Add labels and annotations to operatorgroups when included in namespaces
* v0.9.27: Introduce support for OLMv1 Subscriptions
* v0.9.25: One more update after fixing a relative path issue in the repository builder
* v0.9.23: Update dependencies on helm repository builder.
* v0.9.21: Include dependency on vp-rbac. This will be needed to support OLMv1 subscriptions soon.

**Homepage:** <https://github.com/validatedpatterns/clustergroup-chart>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Validated Patterns Team | <validatedpatterns@googlegroups.com> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.validatedpatterns.io | vp-rbac | 0.1.* |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterGroup.applications | object | `{}` |  |
| clusterGroup.argoCD.configManagementPlugins | list | `[]` |  |
| clusterGroup.argoCD.initContainers | list | `[]` |  |
| clusterGroup.argoCD.resourceExclusions | string | `"- apiGroups:\n  - tekton.dev\n  kinds:\n  - TaskRun\n  - PipelineRun\n"` |  |
| clusterGroup.argoCD.resourceHealthChecks[0].check | string | `"hs = {}\nif obj.status ~= nil then\n  if obj.status.phase ~= nil then\n    if obj.status.phase == \"Pending\" then\n      hs.status = \"Healthy\"\n      hs.message = obj.status.phase\n      return hs\n    elseif obj.status.phase == \"Bound\" then\n      hs.status = \"Healthy\"\n      hs.message = obj.status.phase\n      return hs\n    end\n  end\nend\nhs.status = \"Progressing\"\nhs.message = \"Waiting for PVC\"\nreturn hs\n"` |  |
| clusterGroup.argoCD.resourceHealthChecks[0].kind | string | `"PersistentVolumeClaim"` |  |
| clusterGroup.argoCD.resourceHealthChecks[1].check | string | `"local health_status = {}\n\nhealth_status.status = \"Progressing\"\nhealth_status.message = \"Waiting for InferenceService to report status...\"\n\nif obj.status ~= nil then\n\n  local progressing = false\n  local degraded = false\n  local status_false = 0\n  local status_unknown = 0\n  local msg = \"\"\n\n  if obj.status.modelStatus ~= nil then\n    if obj.status.modelStatus.transitionStatus ~= \"UpToDate\" then\n      if obj.status.modelStatus.transitionStatus == \"InProgress\" then\n        progressing = true\n      else\n        degraded = true\n      end\n      msg = msg .. \"0: transitionStatus | \" .. obj.status.modelStatus.transitionStatus\n    end\n  end\n\n  if obj.status.conditions ~= nil then\n    for i, condition in pairs(obj.status.conditions) do\n\n      -- A condition is healthy if its status is True.\n      -- However, for the 'Stopped' condition, a 'False' status is the healthy state.\n      local is_healthy_condition = (condition.status == \"True\")\n      if condition.type == \"Stopped\" then\n        is_healthy_condition = (condition.status == \"False\")\n      end\n\n      if not is_healthy_condition then\n        -- This condition represents a problem, so update counters and the message.\n        if condition.status == \"Unknown\" then\n          status_unknown = status_unknown + 1\n        else\n          status_false = status_false + 1\n        end\n\n        msg = msg .. \" | \" .. i .. \": \" .. condition.type .. \" | \" .. condition.status\n        if condition.reason ~= nil and condition.reason ~= \"\" then\n          msg = msg .. \" | \" .. condition.reason\n        end\n        if condition.message ~= nil and condition.message ~= \"\" then\n          msg = msg .. \" | \" .. condition.message\n        end\n      end\n\n    end\n\n    if progressing == false and degraded == false and status_unknown == 0 and status_false == 0 then\n      health_status.status = \"Healthy\"\n      msg = \"InferenceService is healthy.\"\n    elseif degraded == false and status_unknown >= 0 then\n      health_status.status = \"Progressing\"\n    else\n      health_status.status = \"Degraded\"\n    end\n\n    health_status.message = msg\n  end\nend\n\nreturn health_status\n"` |  |
| clusterGroup.argoCD.resourceHealthChecks[1].group | string | `"serving.kserve.io"` |  |
| clusterGroup.argoCD.resourceHealthChecks[1].kind | string | `"InferenceService"` |  |
| clusterGroup.argoCD.resourceTrackingMethod | string | `"label"` |  |
| clusterGroup.extraObjects | object | `{}` |  |
| clusterGroup.imperative.activeDeadlineSeconds | int | `3600` |  |
| clusterGroup.imperative.adminClusterRoleName | string | `"imperative-admin-cluster-role"` |  |
| clusterGroup.imperative.adminServiceAccountCreate | bool | `true` |  |
| clusterGroup.imperative.adminServiceAccountName | string | `"imperative-admin-sa"` |  |
| clusterGroup.imperative.clusterRoleName | string | `"imperative-cluster-role"` |  |
| clusterGroup.imperative.clusterRoleYaml | string | `""` |  |
| clusterGroup.imperative.cronJobName | string | `"imperative-cronjob"` |  |
| clusterGroup.imperative.image | string | `"quay.io/validatedpatterns/imperative-container:v1"` |  |
| clusterGroup.imperative.imagePullPolicy | string | `"Always"` |  |
| clusterGroup.imperative.insecureUnsealVaultInsideClusterSchedule | string | `"*/5 * * * *"` |  |
| clusterGroup.imperative.jobName | string | `"imperative-job"` |  |
| clusterGroup.imperative.jobs | list | `[]` |  |
| clusterGroup.imperative.namespace | string | `"imperative"` |  |
| clusterGroup.imperative.roleName | string | `"imperative-role"` |  |
| clusterGroup.imperative.roleYaml | string | `""` |  |
| clusterGroup.imperative.schedule | string | `"*/10 * * * *"` |  |
| clusterGroup.imperative.serviceAccountCreate | bool | `true` |  |
| clusterGroup.imperative.serviceAccountName | string | `"imperative-sa"` |  |
| clusterGroup.imperative.valuesConfigMap | string | `"helm-values-configmap"` |  |
| clusterGroup.imperative.verbosity | string | `""` |  |
| clusterGroup.isHubCluster | bool | `true` |  |
| clusterGroup.managedClusterGroups | object | `{}` |  |
| clusterGroup.name | string | `"example"` |  |
| clusterGroup.namespaces | list | `[]` |  |
| clusterGroup.nodes | list | `[]` |  |
| clusterGroup.sharedValueFiles | list | `[]` |  |
| clusterGroup.subscriptions | object | `{}` |  |
| clusterGroup.targetCluster | string | `"in-cluster"` |  |
| global.extraValueFiles | list | `[]` |  |
| global.options.applicationRetryLimit | int | `20` |  |
| global.options.installPlanApproval | string | `"Automatic"` |  |
| global.options.syncPolicy | string | `"Automatic"` | This defines the global syncpolicy. If set to "Manual", no syncPolicy object will be set, if set to "Automatic" syncPolicy will be set to {automated: {}, retry: { limit: global.options.applicationRetryLimit }}, if set to an object it will be passed directly to the syncPolicy field of the application. Each application can override this |
| global.options.useCSV | bool | `true` |  |
| global.pattern | string | `"common"` |  |
| global.secretLoader.disabled | bool | `false` |  |
| global.secretStore.backend | string | `"vault"` |  |
| global.targetRevision | string | `"main"` |  |
| secretStore.kind | string | `"ClusterSecretStore"` |  |
| secretStore.name | string | `"vault-backend"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
