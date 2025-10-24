#!/usr/bin/env bash

## Run it with
# ./run_pod_jupyter.sh PODMAN_TAG UV_ENV PROJ_FOLDER CONTAINERFILE [ENV_FILE]
# PODMAN_TAG    <- tag for the container
# UV_ENV        <- requirements.txt file for the uv build
# PROJ_FOLDER   <- The project folder to use as working directory and mount point
# CONTAINERFILE <- The path to the Containerfile
# ENV_FILE      <- Optional .env file with folders that need to be mounted

set -euo pipefail # Exit on error, unset variable, or pipe failure

## 1. Argument validation
if [[ $# -lt 4 ]] || [[ $# -gt 5 ]]; then
  echo "Error: Invalid number of arguments." >&2
  echo "Usage: $0 PODMAN_TAG REQ_FILE PROJ_FOLDER CONTAINERFILE [ENV_FILE]" >&2
  exit 1
fi

PODMAN_TAG="$1"
REQ_FILE="$2"
PROJ_FOLDER="$3"
CONTAINERFILE="$4"
ENV_FILE="${5:-}" # Set to empty string if not provided

# Check for existence of mandatory files and directory
if [ ! -f "$REQ_FILE" ]; then
  echo "Error: Requirements file '$REQ_FILE' not found." >&2
  exit 1
fi
if [ ! -d "$PROJ_FOLDER" ]; then
  echo "Error: Project folder '$PROJ_FOLDER' not found." >&2
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
# Prepare volume mounts array, starting with the project folder
declare -a VOLUME_MOUNTS=("-v" "$PROJ_FOLDER:$PROJ_FOLDER")

# If an environment file is provided, parse it for additional mounts
if [ -n "$ENV_FILE" ]; then
  if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file '$ENV_FILE' not found." >&2
    exit 1
  fi

  # Directly parse the ENV_FILE to create volume mount flags
  while IFS= read -r line; do
    path_value=$(echo "$line" | cut -d'=' -f2-)
    path_value="${path_value%\"}"; path_value="${path_value#\"}"
    path_value="${path_value%\'}"; path_value="${path_value#\'}"

    if [ -n "$path_value" ]; then
      VOLUME_MOUNTS+=("-v" "$path_value:$path_value")
    fi
  done < <(grep -E '^\s*(export\s+)?[A-Za-z_][A-Za-z0-9_]*=' "$ENV_FILE")
fi

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
  bash -c "EUPORIE_GRAPHICS=sixel EUPORIE_EDIT_MODE=vi EUPORIE_CLIPBOARD=external EUPORIE_MOUSE_SUPPORT=true euporie-console"

# commands to use
# -c "jupyter server --allow-root"
# -c "EUPORIE_GRAPHICS=sixel EUPORIE_EDIT_MODE=vi EUPORIE_CLIPBOARD=external EUPORIE_MOUSE_SUPPORT=true euporie-console"


## Build Singularity image without cache
# podman build --no-cache -t endo_on_chip .
## pack it to a tar
# podman save -o endo_on_chip.tar --format oci-archive endo_on_chip:latest 
## and convert to a SIF file
# apptainer build endo_on_chip.sif oci-archive://endo_on_chip.tar
