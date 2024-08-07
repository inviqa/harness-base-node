# Harness Base Node for [Workspace]

A [Workspace] harness is a way to ship files to a project without being part of the project.

In this repository are a set of harnesses that have been created for the NodeJS language, reducing the maintenance overhead
of the individual harnesses greatly. This is due to the "base" node harness being used as a common set of templates.

Each framework will fully override a base harness file if differing behaviour is required.

## Available Frameworks

- [NextJs](src/nextjs/)

## Features of each harness

- Local docker compose development environment
- Skeleton for simple set-up of new projects
- Pipeline docker compose environment for use in Jenkins or other tools to run tests
- TODO: Helm chart for deploying QA, UAT and Production environments to Kubernetes clusters

## Harness Upgrade Instructions

A developer for a project can follow these steps to upgrade their harness version:

1. Check the [version specific upgrade instructions] for the new version to see if there are any specific steps. If
   upgrading through multiple versions, check the previous version's instructions too!
2. Check what harness is in use for the project. This is usually line 2 or 3 in `workspace.yml`.
3. Update the `workspace.yml` harness version (usually line 2 or 3) to the new tagged version.
4. Download the new harness version:

```bash
rm -rf .my127ws
ws harness download
```

5. Perform a recursive diff between the new release from the checked out harness from step 1 and any "overlay"
   directories such as `tools/workspace/`.
   1. Remove any files from the project that are now the same as the harness.
   2. Port over any changes from the harness to override files that must stay.
6. Render the templates and apply the overlay directory:

```bash
ws harness prepare
```

7. Perform a recursive diff between the `.my127ws/application/skeleton/` folder to the project root:
   1. If a skeleton file (that isn't in a `_twig` folder or named `*.twig`) is missing, copy it to the project
   2. If a project file is missing some changes from the skeleton, try applying the change from the skeleton.
   3. Port over new features such as new standard dev tooling in composer.json.
   4. Ensure the README.md is up to date, though keep any changes made to the project's README.md over time.
8. Compare the overrides for attributes in the project's `workspace.yml` to the harness's `harness.yml` and `harness/attributes/*.yml`.
   1. Port over any additional build, init or migrate steps.
   2. Remove any attribute overrides from workspace.yml that are now the same as the harness.
9. Test with `ws harness update existing`
10. Open a pull request with the project and ensure CI checks (such as Jenkins) pass.
11. Note on the pull request that to apply the changes, the following needs to be done by the project team:

```markdown
To keep your existing database:
`ws harness update existing`

To do a fresh installation:
`ws harness update fresh`
```

12. Ask for someone else to test the pull request.
13. Once the pull request has been merged to the default branch of the project, remind the project team to apply the changes with the `ws harness update existing` or `ws harness update fresh` commands.

### Memory

The memory requests for pods have been deliberately set to be the same as the limits.

This is to avoid nodes going to "NotReady" status due to dockerd/containerd/kubelet being killed by the kernel.

An example:
Requesting 10Mi of memory but allowing the pod to spike to 1024Mi means that kubernetes will schedule the pod it onto a
node with 10Mi allocatable memory left. It doesn't consider the limits at all when scheduling pods.

As soon as something in the pod starts using more than 10Mi when the node is already at capacity, kubelet attempts to
kill processes in the container to get back down to 10Mi.

Sometimes kubelet does not manage to kick in fast enough and the Linux kernel's Out Of Memory (OOM) killer kicks in
instead. Whilst core kubernetes processes such as dockerd, containerd and kubelet have an extremely low priority for
the OOMKiller, sometimes the kernel decides to kill one of these core processes anyway as it would free up the most
memory, leading to the node having issues.

## Testing

The final harness version for each of the frameworks is put together by the [build script](./build) into a "dist"
folder. This is used for testing in Jenkins.

### Quality check

We run shellcheck and hadolint across shell scripts and Dockerfiles. These can be run via:

```bash
./quality
```

The `./test` script described below also runs these quality checks against rendered twig templates in
`tmp-test-<framework>-<mode>/.my127ws/` as used in a test project.

### End to end tests with the secret key

If you have access to the secret key needed to decrypt the src/.ci/\*/workspace.yml encrypted attributes, you can run
the following to test the given framework in the given mode like Jenkins does:

```bash
./build && ./test <framework> <static|dynamic> [mutagen]
```

Running with the environment variable `TEARDOWN_ENVIRONMENT=no` will keep the environment running so you can
debug a failure.

### End to end tests without the secret key

If you don't have access to the key, you can still bring up a test environment:

1. Run `./build`
2. Create and change to a tests directory

```bash
mkdir tests
cd tests
ws create <framework>-test inviqa/<framework> --no-install
```

3. Copy the built version of harness-base-node's `./dist/<framework>` dir to `<framework>-test/.my127ws` directory

```bash
cp -pR ../dist/harness-<framework>/ <framework>-test/.my127ws/
```

4. Change directory to `<framework>-test`

```bash
cd `<framework>-test`
```

5. Update the override file in `<framework>-test`:

```bash
echo "attribute('mutagen'): no" >> workspace.override.yml
```

6. Run in `pipeline` mode to activate `static` mode

```bash
MY127WS_ENV=pipeline ws install
```

## Deployment

### Release archives

Once a Github release has been created, a Github Action will build and create archives of each harness and upload them to the release.

## Release

### Changelog Generation

We use Gitlab release notes to generate and store changelogs.

When ready to tag a release, make a new branch from the `0.5.x` branch for the changelog entries:

1. Draft a release (don't publish it) https://github.com/inviqa/harness-base-node/releases/new?tag=0.5.0&title=0.5.0target=main
2. Click `Generate release notes`
3. Examine the release notes. For every entry in the `Other Changes` section, examine the Pull Requests
   and assign each pull request either a `enhancement` label for a new feature, `bug` for a bugfix or `deprecated` for
   a deprecation.
4. For each Pull Request in the release, assign an appropriate `harness-*` label.
5. Re-generate the changelog using step 2 as needed. Clearing the release notes to allow regeneration.
6. Commit the resulting changes, push and raise a pull request.
7. Once merged, continue with the release process below.

### Performing a Release

When you're ready to release:

1. Draft a new release https://github.com/inviqa/harness-base-node/releases/new?tag=0.5.0&title=0.5.0&target=main
2. Click `Generate release notes`
3. Publish the release
4. Submit a pull request to [my127/my127.io] which adds the new release version and asset download URL for the
   nodejs-based harnesses to `harnesses.json`

[Workspace]: https://github.com/my127/workspace
[inviqa/harness-nextjs]: https://github.com/inviqa/harness-base-node/tree/main/src/nextjs
[my127/my127.io]: https://github.com/my127/my127.io
