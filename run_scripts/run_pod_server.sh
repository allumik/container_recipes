#!/usr/bin/env bash

## Run it with
# ./run_pod_jupyter.sh PODMAN_TAG UV_ENV PROJ_FOLDER ENV_FILE CONTAINERFILE
# PODMAN_TAG <- tag for the container
# UV_ENV <- requirements.txt file for the uv build
# PROJ_FOLDER <- The project folder to use as working directory and mount point
# ENV_FILE <- .env file with folders that need to be mounted
# CONTAINERFILE <- The path to the Containerfile

set -euo pipefail # Exit on error, unset variable, or pipe failure

## 1. Argument validation
if [[ $# -ne 5 ]]; then
  echo "Error: Invalid number of arguments." >&2
  echo "Usage: $0 PODMAN_TAG REQ_FILE PROJ_FOLDER ENV_FILE CONTAINERFILE" >&2
  echo "PODMAN_TAG <- tag for the container" >&2
  echo "UV_ENV <- requirements.txt file for the uv build" >&2
  echo "PROJ_FOLDER <- The project folder to use as working directory and mount point" >&2
  echo "ENV_FILE <- .env file with folders that need to be mounted" >&2
  echo "CONTAINERFILE <- The path to the Containerfile" >&2
  exit 1
fi

PODMAN_TAG="$1"
REQ_FILE="$2"
PROJ_FOLDER="$3"
ENV_FILE="$4"
CONTAINERFILE="$5"

# Check for file and directory existence
if [ ! -f "$REQ_FILE" ]; then
  echo "Error: Requirements file '$REQ_FILE' not found." >&2
  exit 1
fi
if [ ! -d "$PROJ_FOLDER" ]; then
  echo "Error: Project folder '$PROJ_FOLDER' not found." >&2
  exit 1
fi
if [ ! -f "$ENV_FILE" ]; then
  echo "Error: Environment file '$ENV_FILE' not found." >&2
  exit 1
fi
if [ ! -f "$CONTAINERFILE" ]; then
  echo "Error: Containerfile '$CONTAINERFILE' not found." >&2
  exit 1
fi

## 2. BUILD the image
cp "$REQ_FILE" ./requirements.txt
# Ensure cleanup of the symlink on script exit
trap 'rm ./requirements.txt' EXIT
podman build -f "$CONTAINERFILE" -t "$PODMAN_TAG" .

## 3. RUN the image
# Prepare volume mounts array
declare -a VOLUME_MOUNTS=("-v" "$PROJ_FOLDER:$PROJ_FOLDER")

# Directly parse the ENV_FILE to create volume mount flags
while IFS= read -r line; do
  path_value=$(echo "$line" | cut -d'=' -f2-)
  path_value="${path_value%\"}"; path_value="${path_value#\"}"
  path_value="${path_value%\'}"; path_value="${path_value#\'}"

  if [ -n "$path_value" ]; then
    VOLUME_MOUNTS+=("-v" "$path_value:$path_value")
  fi
done < <(grep -E '^\s*(export\s+)?[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE")

# Execute podman run command
podman run \
  -it \
  --rm \
  --device=/dev/kfd \
  --device=/dev/dri \
  --group-add=video \
  --network=host \
  --ipc=host \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  -w "$PROJ_FOLDER" \
  "${VOLUME_MOUNTS[@]}" \
  --name py_env \
  "$PODMAN_TAG" \
  bash -c "jupyter server --allow-root"


## Build Singularity image without cache
# podman build --no-cache -t endo_on_chip .
## pack it to a tar
# podman save -o endo_on_chip.tar --format oci-archive endo_on_chip:latest 
## and convert to a SIF file
# apptainer build endo_on_chip.sif oci-archive://endo_on_chip.tar
