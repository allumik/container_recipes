# Container for a pile of containers

The repo that youre looking at consists of general experimentations with containers for my research (or hobbies). Currently, following images are described here:

* dockerhub: [allumik/r-ml](https://hub.docker.com/r/allumik/r-ml)
* dockerhub: [allumik/r-bioverse](https://hub.docker.com/r/allumik/r-bioverse)
  
## Structure

### Dockerfiles

Dockerfiles for Docker...

### Singularity recipes

`def` files for building `sif` images to be run in SingularityCE.

### Build scripts

`build.ps1` - build script for `pwsh` shell, chaining the build of Docker baseline images with [SingularityCE](https://docs.sylabs.io/guides/latest/user-guide/) images. It depends on WSL (Ubuntu) with SingularityCE installed.