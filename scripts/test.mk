# Fedora version to build and test (defaults to the latest supported version)
version_branch ?= 43

# Local image and container names used by the test build
TEST_IMAGE ?= docker-fedora-ansible
TEST_CONTAINER ?= test-container

# Smoke test mirroring .github/workflows/test-image.yml:
# build the image for version_branch, run it, verify Ansible is usable,
# then remove the created container and image. Cleanup also runs on failure.
test-build:
	@set -e; \
	image="$(TEST_IMAGE):$(version_branch)"; \
	container="$(TEST_CONTAINER)"; \
	cleanup() { podman rm -f "$$container" >/dev/null 2>&1 || true; podman rmi -f "$$image" >/dev/null 2>&1 || true; }; \
	trap cleanup EXIT; \
	podman build -t "$$image" ./fedora$(version_branch)/.; \
	podman run --name "$$container" --detach --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro "$$image"; \
	podman exec --tty "$$container" env TERM=xterm ansible --version

.PHONY: test-build