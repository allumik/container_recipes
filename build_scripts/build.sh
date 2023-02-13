#!/bin/env/bash

## Bash version of the build process, meant for MacOS
## in linux you can run singularity natively

# Build the Docker base container
cat ../dockerfiles/r-bioverse.Dockerfile | docker build --progress=plain --tag "allumik/r-bioverse" - >> ./build.log

# Push it to DockerHub
docker image push allumik/r-bioverse

# Build Docker container for Singularity/Apptainer
cat ../dockerfiles/sif-build.Dockerfile | docker build --progress=plain --tag "allumik/sif-builder" - >> ./build.log

# Run Singularity/Apptainer
vagrant ssh -c "cd /vagrant/project/ && apptainer build --force ./r-bioverse-dev.sif ./def_files/r-bioverse-dev.def" | tee ./build.log