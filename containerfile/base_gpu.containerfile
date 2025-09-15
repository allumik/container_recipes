# Use the NVIDIA CUDA base image
FROM nvidia/cuda:12.6.3-base-ubuntu24.04

# Set labels
LABEL maintainer="Alvin Meltsov"
LABEL ubuntu_version="Ubuntu Noble with CUDA enabled"

# Update and install necessary packages
RUN apt-get update -qq && \
  apt-get upgrade -y && \
  apt-get install -y --no-install-recommends \
    build-essential \
    gpg \
    wget \
    curl \
    locales \
    automake \
    autoconf \
    pkg-config \
    bzip2 \
    cmake \
    glibc-source \
    libc-devtools \
    libc6 \
    libc6-dev \
    libxml2-dev \
    libxslt1-dev \
    libpng-dev \
    libgit2-dev \
    libssl-dev \
    libssh2-1-dev \
    libcurl4-openssl-dev \
    libbz2-dev \
    liblzma-dev \
    libfontconfig-dev \
    libjpeg8-dev \
    libffi-dev \
    zlib1g-dev && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install Quarto
RUN wget --no-check-certificate https://quarto.org/download/latest/quarto-linux-amd64.deb && \
  dpkg --install quarto-linux-amd64.deb && \
  rm quarto-linux-amd64.deb