#!/bin/env/bash

## Bash version of the build process, meant for MacOS
## in linux you can run singularity natively

# Build the Docker base container
docker build --progress=plain --tag "allumik/r-bioverse" - < ../dockerfiles/r-bioverse.Dockerfile >> ./build.log

# Push it to DockerHub
docker image push allumik/r-bioverse
# docker image push allumik/r-bioverse:ubuntu
# docker image push allumik/r-bioverse:dev

# Build Docker container for Singularity/Apptainer
docker build --progress=plain --tag "allumik/sif-builder" - < ../dockerfiles/sif-builder.Dockerfile >> ./build.log

# Run Singularity/Apptainer from docker
docker exec apptainer build ./test.sif ./def_files/r-bioverse.def

vagrant up && vagrant ssh -c "cd /vagrant/project/ && apptainer build --force ./r-bioverse-dev.sif ./def_files/r-bioverse-dev.def" | tee ./build.log

## ☕️

## Anything went wrong while you were out?
# cat "./build.log" | grep error