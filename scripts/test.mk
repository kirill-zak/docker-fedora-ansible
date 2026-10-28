# Fedora version to build and test (defaults to the latest supported version)
version_branch ?= 42

# Local image and container names used by the test build
TEST_IMAGE ?= docker-fedora-ansible
TEST_CONTAINER ?= test-container

# Smoke test mirroring .github/workflows/test-image.yml:
# build the image for version_branch, run it, and verify Ansible is usable.
# The container is removed first so the target can be re-run.
test-build:
	podman build -t $(TEST_IMAGE):$(version_branch) ./fedora$(version_branch)/.
	-podman rm -f $(TEST_CONTAINER)
	podman run --name $(TEST_CONTAINER) --detach --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro $(TEST_IMAGE):$(version_branch)
	podman exec --tty $(TEST_CONTAINER) env TERM=xterm ansible --version

.PHONY: test-build