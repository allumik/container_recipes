## >>> "r-bioverse" <<<
## allumik/r-bioverse
## R bioinf focused development docker with radian terminal
## `--gpus all` ... to utilize GPU's
## `ROOT=true` ... to add default user to sudoers
## `DISABLE_AUTH=true` ... disable authentification when logging into rstudio

FROM rocker/verse:4.2
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

# default user: "rstudio"
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8

# Update and install some deps for building bioconductor
RUN apt update -qq \
    && apt -y --no-install-recommends install \
        libxml2-dev libcurl4-openssl-dev libpng-dev \
        libgit2-dev gfortran libbz2-dev liblzma-dev libssh2-1-dev \
        autoconf automake g++ gcc make libclang-dev \
        openssh-client openssh-server python3 python3-pip \
    && apt clean all \
    && rm -rf /var/lib/apt/lists/*


# Install main packages in R
RUN install2.r --error -n 8 -s \
      BiocManager snow plotly glue feather reactable \
      jsonlite languageserver jsonlite magrittr renv knitr \
      tidymodels recipes
# Install Bioconductor packages and clean up temporary files
RUN R -e 'BiocManager::install(c( \
        "DESeq2", "edgeR", "limma", "sva", "rtracklayer", \
        "biomaRt", "GenomicRanges", "BiocParallel", \
        "Rsamtools", "GenomicAlignments" ))'
# Install extra packages
RUN install2.r --error -n 8 -s \
      ggpubr ggvenn modelr heatmaply viridis RColorBrewer \
      embed broom devEMF mltools vip showtext umap writexl \
      Exact corrr statmod tictoc psych ranger remotes git2r \
      xgboost rmdformats doParallel \
    && rm -rf /tmp/downloaded_packages /tmp/*.rds


# Install radian
RUN python3 -m pip --no-cache-dir install --upgrade --ignore-installed radian
