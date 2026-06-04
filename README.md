# clustergroup

![Version: 0.9.53](https://img.shields.io/badge/Version-0.9.53-informational?style=flat-square)

A Helm chart to create per-clustergroup ArgoCD applications and any required namespaces or subscriptions.

This chart is used to set up the basic building blocks in [Validated Patterns](https://validatedpatterns.io)

### Notable changes

* v0.9.53: Add .values.global.singleArgoCD support
* v0.9.52: Add ansibleDevMode (requirements.yml injection and optional ansibleCfgFile/ansibleCfgContent) to simplify rhvp.cluster_utils development. Add extraPlaybookArgs to imperative as well.
* v0.9.50: Add support to custom `rbac` in `ArgoDC.spec`
* v0.9.49: Boolean Templates in override values now also render correctly
* v0.9.48: Templates in override values now render
* v0.9.45: Default value of `resourceTrackingMethod` is now `annotation`
* v0.9.44: Default value of `resourceTrackingMethod` is now `annotation`
* v0.9.43: Add support to `env`, `volumes` and `volumeMounts` in repository server
* v0.9.38: Ensure sharedValueFiles and extraValueFiles are always prefixed with $patternref
* v0.9.37: Use global.patternDelete value set by patterns operator when patterns are deleted
* v0.9.32: Add labels and annotations to operatorgroups when included in namespaces
* v0.9.27: Introduce support for OLMv1 Subscriptions
* v0.9.25: One more update after fixing a relative path issue in the repository builder
* v0.9.23: Update dependencies on helm repository builder.
* v0.9.21: Include dependency on vp-rbac. This will be needed to support OLMv1 subscriptions soon.

### Resource Actions

Custom resource actions can be configured on the ArgoCD instance via `clusterGroup.argoCD.resourceActions`.
This allows defining Lua-based actions that appear in the ArgoCD UI for specific resource kinds.

For example, to add a "scale up" action for Deployments:

```yaml
clusterGroup:
  argoCD:
    resourceActions:
      - group: apps
        kind: Deployment
        action: |
          local os = require("os")
          local actions = {}
          actions["scale-up"] = {["disabled"] = false}
          local replicas = 1
          if obj.spec.replicas ~= nil then
            replicas = obj.spec.replicas + 1
          end
          local patch = {["spec"] = {["replicas"] = replicas}}
          return actions, patch
```

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
| clusterGroup.argoCD.env | list | `[]` |  |
| clusterGroup.argoCD.initContainers | list | `[]` |  |
| clusterGroup.argoCD.rbac | object | `{}` |  |
| clusterGroup.argoCD.resourceActions | list | `[]` |  |
| clusterGroup.argoCD.resourceExclusions | string | `"- apiGroups:\n  - tekton.dev\n  kinds:\n  - TaskRun\n  - PipelineRun\n"` |  |
| clusterGroup.argoCD.resourceHealthChecks[0].check | string | `"hs = {}\nif obj.status ~= nil then\n  if obj.status.phase ~= nil then\n    if obj.status.phase == \"Pending\" then\n      hs.status = \"Healthy\"\n      hs.message = obj.status.phase\n      return hs\n    elseif obj.status.phase == \"Bound\" then\n      hs.status = \"Healthy\"\n      hs.message = obj.status.phase\n      return hs\n    end\n  end\nend\nhs.status = \"Progressing\"\nhs.message = \"Waiting for PVC\"\nreturn hs\n"` |  |
| clusterGroup.argoCD.resourceHealthChecks[0].kind | string | `"PersistentVolumeClaim"` |  |
| clusterGroup.argoCD.resourceTrackingMethod | string | `"annotation"` |  |
| clusterGroup.argoCD.volumeMounts | list | `[]` |  |
| clusterGroup.argoCD.volumes | list | `[]` |  |
| clusterGroup.extraObjects | object | `{}` |  |
| clusterGroup.imperative.activeDeadlineSeconds | int | `3600` |  |
| clusterGroup.imperative.adminClusterRoleName | string | `"imperative-admin-cluster-role"` |  |
| clusterGroup.imperative.adminServiceAccountCreate | bool | `true` |  |
| clusterGroup.imperative.adminServiceAccountName | string | `"imperative-admin-sa"` |  |
| clusterGroup.imperative.ansibleDevMode.ansibleCfgContent | string | `""` | Inline ansible.cfg; when non-empty, written to ansibleCfgFile before ansible-galaxy (so galaxy and playbooks honor collections_path, etc.). |
| clusterGroup.imperative.ansibleDevMode.ansibleCfgFile | string | `"ansible.cfg"` | Path under the cloned pattern repo for optional injected ansible.cfg (written from ansibleCfgContent when set). |
| clusterGroup.imperative.ansibleDevMode.enabled | bool | `false` | When true, run an init container before imperative playbooks that can install collections and optionally write ansible.cfg into the cloned repo (/git/repo). |
| clusterGroup.imperative.ansibleDevMode.requirementsContent | string | `""` | Inline requirements.yml; when non-empty, written to requirementsFile before galaxy install. |
| clusterGroup.imperative.ansibleDevMode.requirementsFile | string | `"requirements.yml"` | Path under the cloned pattern repo for ansible-galaxy -r (written from requirementsContent when set). |
| clusterGroup.imperative.clusterRoleName | string | `"imperative-cluster-role"` |  |
| clusterGroup.imperative.clusterRoleYaml | string | `""` |  |
| clusterGroup.imperative.cronJobName | string | `"imperative-cronjob"` |  |
| clusterGroup.imperative.extraPlaybookArgs | list | `[]` | Optional extra arguments for every ansible-playbook invocation (imperative jobs, vault unseal, auto-approve installplans). Each list entry is one argv token. Empty by default. |
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
| global.singleArgoCD | bool | `false` | When set to true, a single ArgoCD instance (in `global.vpArgoNamespace`) is used instead of creating a per-clustergroup instance |
| global.targetRevision | string | `"main"` |  |
| global.vpArgoNamespace | string | `"openshift-gitops"` |  |
| secretStore.kind | string | `"ClusterSecretStore"` |  |
| secretStore.name | string | `"vault-backend"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
