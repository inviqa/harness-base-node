# Upgrade Guide

In addition to the README's [Harness Upgrade Instructions], please note these specific version upgrade instructions.

## Upgrading from 1.0.x to 1.1.x

### Buildkit

Buildkit is now used for docker image builds both in Jenkins and locally.

To opt out from buildkit in Jenkins, set `attribute('jenkins.docker.buildkit.enabled'): false`.

To opt out from buildkit locally, set `attribute('docker.buildkit.enabled'): false`.

### Jenkins

#### Minimal Build

Jenkins now performs a minimal build with the `node` docker image and no supporting services,
to allow faster feedback for linting or unit test issues.
If this minimal build passes, Jenkins will launch a full build to run integration tests.

If linting or unit tests need supporting services like a database or cache to be available,
set `attribute('jenkins.tests.isolated'): true` to revert to the old behaviour.

#### Lighthouse

Jenkins now runs a Lighthouse check against the default URL of the site as an integration test.
The URL being tested can be configured with `attribute('lighthouse.target.url')`.

Thresholds for passing scores can also be configured by setting the `enabled` (true/false) and `score` (integer)
of these attributes:
```yaml
lighthouse:
  success-thresholds:
    pwa:
      enabled: false
      score: 0
    seo:
      enabled: false
      score: 0
    best-practices:
      enabled: false
      score: 0
    accessibility:
      enabled: false
      score: 0
    performance:
      enabled: false
      score: 0
```

## Upgrading from 0.12.x to 1.0.x

### Removal of docker-sync

If you use docker-sync on macOS, you can convert to mutagen with the following commands:
```bash
docker-sync stop
docker rm "<workspace-project-name>-sync"
ws switch mutagen
```

### Removed attributes

* `attribute('pipeline.publish.chart.git.key')` - replaced with `attribute('pipeline.publish.chart.git.ssh_private_key')`
* `attribute('docker.config')` - replaced with `attribute('docker.image_pull_config')`
* `attribute('git.main_branch')` - replaced with `attribute('git.default_branch')`
* `attribute('resources.cpu.requests.<service>')` - no equivalent
* `attribute('resources.cpu.limits.<service>')` - no equivalent
* `attribute('resources.memory.<service>')` - replaced with `attribute('services.<service>.resources.memory')`
* `attribute('resources.memory.app_init')` - replaced with `attribute('services.console.resources.init_memory')`
* `attribute('resources.memory.app_migrate')` - replaced with `attribute('services.console.resources.migrate_memory')`
* `attribute('pipeline.preview.resources.memory.<service>')` - replaced with `attribute('pipeline.preview.services.<service>.resources.memory')`
* `attribute('pipeline.production.resources.memory.<service>')` - replaced with `attribute('pipeline.production.services.<service>.resources.memory')`

### Removed functions

* The function `deep_merge_to_yaml` has been removed. Please convert from:
```yaml
deep_merge_to_yaml([...], 2, 2)
```
to:
```yaml
to_nice_yaml(deep_merge([...]), 2, 2)
```

### Renamed attributes

* If you use AWS for asset downloads, rename `attribute('aws.id')` to `attribute('aws.access_key_id')` and
`attribute('aws.key')` to `attribute('aws.secret_access_key')`
* Magento 2's static content deploy attribute `attribute('magento.static_content.backend')` is now
`attribute('magento.static_content.adminhtml')`
* Any attributes mentioning `redis_session` should be renamed to `redis-session`

### Removed templates

The following templates have been removed:
* _twig/docker-compose.yml/application.yml.twig - replaced with _twig/docker-compose.yml/service/console.yml.twig and _twig/docker-compose.yml/service/webapp.yml.twig
* _twig/docker-compose.yml/environment.yml.twig - replaced with `attribute('services.php-base.environment')` and `attribute('services.php-base.environment_secrets')`
* helm/app/_twig/values.yaml/environment.yml.twig - replaced with `harness/attributes/docker*.yml` which can be used via `attribute('services.<service>.environment')`
* helm/app/_twig/values.yaml/resources.yml.twig - replaced with `.Values.services.<service>.resources.memory`

### Helm charts

* `.Values.service.<service>` true/false enabled array is now `.Values.services.<service>.enabled`, as set by `attribute('services.<service>.enabled')`
* `.Values.docker.services` is now `.Values.services`, as set by `attribute('services')` run through a `filter_local_services()` function call, which restricts which keys are available to helm to exclude environment_secrets.
* `.Values.docker.image.<service>` is now `.Values.services.<service>.image`
* `.Values.resources.memory.<service>` is now `.Values.services.<service>.resources.memory`
* Now only compatible with Kubernetes 1.16+ due to ingress API version changes

## Upgrading from 0.11.x to 0.12.x


### Helm charts

Helm-standard labels have been added to all resources which will cause a redeployment of all services. This will incur
downtime for any services that use persistent storage backed by ReadWriteOnce volume (i.e. anything that isn't NFS).

[Harness Upgrade Instructions]: https://github.com/inviqa/harness-base-php#harness-upgrade-instructions
