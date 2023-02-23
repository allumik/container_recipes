#!/usr/bin/env bash

## Bash version of the build process, meant for MacOS
## in linux you can run singularity natively

# Get the project full path from the parent folder
PRJ_PATH=$(pwd ..)

## Build the Docker base container
docker build --progress=plain --tag "allumik/r-bioverse" - < "$PRJ_PATH/dockerfiles/r-bioverse.Dockerfile" >> "$PRJ_PATH/build.log"

## Push it to DockerHub
docker image push allumik/r-bioverse
# docker image push allumik/r-bioverse:ubuntu
# docker image push allumik/r-bioverse:dev

## Build Docker container for Singularity/Apptainer
docker build --progress=plain --tag "allumik/sif-builder" - < "$PRJ_PATH/dockerfiles/sif-build.Dockerfile" >> "$PRJ_PATH/build.log"

## Run Singularity/Apptainer from docker as privileged user
# --force  to overwrite current SIF
docker run --privileged -v "$PRJ_PATH":"/app" allumik/sif-builder build /app/r-bioverse-dev.sif /app/def_files/r-bioverse-dev.def >> "$PRJ_PATH/build.log"

## Build the docker dev image for VSCode etc
docker build --progress=plain --tag "allumik/r-bioverse:dev" - < "$PRJ_PATH/dockerfiles/r-bioverse-dev.Dockerfile" >> "$PRJ_PATH/build.log"
docker image push allumik/r-bioverse:dev

## ☕️

## Anything went wrong while browsing HackerNews?
# cat "./build.log" | grep error