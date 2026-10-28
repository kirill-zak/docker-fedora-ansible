# AGENTS.md

Guidance for AI coding agents working in this repository.

## About the project
docker-fedora-ansible is a Fedora (43–44) image with Ansible pre-installed,
designed for testing playbooks and roles. All versions live in a single repository
and are published under different tags to Docker Hub and GHCR.

## Repository structure
- `fedora<version>/` — separate build context: `Dockerfile`, `.dockerignore`.
- `.github/workflows/`:
  - `ci.yml` — checks on PR/push to master; calls reusable `test-image.yml`.
  - `build.yml` — manual build check across all platforms (`workflow_dispatch`);
    calls reusable `build-image.yml` with `push: false`.
  - `release.yml` — publishing on tags: `validate-tag` → `config` → `test` → matrix
    `release` (reusable `build-image.yml`, `secrets: inherit`).
  - `config.yml` — reusable workflow, single source of constants: outputs
    `versions` (JSON array), `platforms` (JSON array), `latest_version` (string);
    callers drive their matrices from `needs.config.outputs.*`.
  - `test-image.yml`, `build-image.yml` — reusable workflows with shared steps.
- `Makefile` + `scripts/test.mk` — `make test-build` smoke test mirroring
  `test-image.yml`; the version is set via the `version_branch` variable (default:
  the latest supported version).
- `.context/optimize-ci.md` — CI/CD architecture plan and rationale (read before
  changing the workflows).
- `.gitignore` — files kept out of git (`.context`, `.omo`).

## Build and test
- Local build: `cd fedora44 && docker build -t docker-fedora-ansible .`
- Smoke test (as in CI, `test-image.yml`):
  1. `podman build -t docker-fedora-ansible:<version> ./fedora<version>/.`
  2. `podman run --name test-container --detach --privileged \
     --volume /sys/fs/cgroup:/sys/fs/cgroup:ro docker-fedora-ansible:<version>`
  3. `podman exec --tty test-container env TERM=xterm ansible --version`
- Or via the Makefile: `make test-build` (override the version with
  `make test-build version_branch=43`).

## CI/CD conventions
- Version matrix: `43, 44`.
- Versions, platforms, and the `latest` tag mapping live in `config.yml`
  (outputs `versions`, `platforms`, `latest_version`) — edit it to change the
  build/test matrix; no other workflow needs editing for a version change.
- `35`–`42` are archived — no longer built or published (see README,
  "Archive tags").
- README lists tags and archive tags in descending version order.
- Platforms: `linux/amd64`, `linux/arm64`, `linux/ppc64le`, `linux/s390x`.
- Release tag: `x.x` or `x.x.x`, optional `v` prefix
  (regex `^v?[0-9]{1,2}\.[0-9]{1,2}(\.[0-9]{1,2})?$`), no suffixes — enforced by
  the `validate-tag` job.
- `GITHUB_TOKEN` permissions are minimal: workflow-level `contents: read`.
  Registry-capable callers grant `packages: write` on their calling job
  (`release` in `release.yml`, `test-build` in `build.yml`), and `build-image.yml`
  requests it on the `build` job. Note: a called workflow's token is the
  *intersection* of the caller job's and the called job's permissions.
- Images are published to Docker Hub (`kirillzak/docker-fedora-ansible`) and GHCR
  (`ghcr.io/<owner>/<repo>`).
- Dockerfiles declare `ARG BUILDPLATFORM` without a default value so podman/buildah
  do not fail with "attempted to redefine BUILDPLATFORM".

## Commit message conventions
Use Conventional Commits. Prefixes used in this repository:

- `feat:` — new functionality.
- `fix:` — correction of errors.

Other types (`docs:`, `refactor:`, `chore:`, `ci:`, `test:`) may be used when
`feat:`/`fix:` do not fit.

Guidelines:

- Messages and code comments are in English.
- The subject (first line) should be as short as possible; hard limit: 70 characters
  for the whole message, so a body should not be needed.
- Describe only what was done — do not mention plans or tasks in the message.

## How to add a new Fedora version
1. Create `fedora<version>/` with `Dockerfile` and `.dockerignore`.
2. Add `"<version>"` to the `versions` output in `.github/workflows/config.yml`
   (and update `latest_version` there if the new version becomes `latest`); add the
   tag to README in descending order.
3. If the new version is the latest, update the `version_branch` default in
   `scripts/test.mk`.
4. Run `workflow_dispatch` on `build.yml` and run the local smoke test
   (`make test-build`).