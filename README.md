# docker-fedora-ansible
Fedora docker container with built-in Ansible for playbook and role testing

# The main goal
Keep all version in one repository under different tags

## Tags
- `35`. Fedora 35
- `36`. Fedora 36
- `37`. Fedora 37
- `38`. Fedora 38
- `39`. Fedora 39
- `40`. Fedora 40

## How to Build

To build the image on your own locally, do the following:

  1. [Install Docker](https://docs.docker.com/engine/installation/).
  2. `cd` into target directory. For example, target directory for `Fedora 40` is `fedora40`
  3. Run `docker build -t docker-fedora-ansible .`.

  ## How to Use

  1. [Install Docker](https://docs.docker.com/engine/installation/).
  2. Pull pre-build image via `docker image pull kirillzak/docker-fedora-ansible:latest` or build image.
  3. Run a container from the image: `docker run --detach --privileged --volume /sys/fs/cgroup:/sys/fs/cgroup:ro docker-fedora-ansible:latest`

## Author

[Kirill Ziuzin](https://kirill-zak.ru/)

### Thanks
Thanks for [Jeff Geerling](https://github.com/geerlingguy)

### Based
Based on:
- https://github.com/geerlingguy/docker-fedora35-ansible
- https://github.com/geerlingguy/docker-fedora36-ansible
- https://github.com/geerlingguy/docker-fedora37-ansible