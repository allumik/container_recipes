#!/bin/bash

export MAMBA_ROOT_PREFIX=/opt/micromamba
export PATH="$MAMBA_ROOT_PREFIX/bin:$PATH"
micromamba shell init --shell bash
micromamba shell hook -s bash
