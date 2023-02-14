## >>> "r-bioverse" <<<
## allumik/r-bioverse:fat
## R bioinf focused development docker based on Ubuntu.

FROM ubuntu:jammy
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

# Set the locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
## ensure installation is stripped
ENV DEBIAN_FRONTEND=noninteractive
## set timezone to be UTC
ENV TZ=UTC

## Update Ubuntu and install the base deps
RUN apt update -q -q && apt upgrade -y \
    && apt install -y \
      locales \
      build-essential \
      gfortran \
      make \
      wget \
      libc6 libc6-dev \
      ca-certificates \
      libxml2-dev \
      libjpeg-turbo8-dev \
      libpng-dev \
      libgit2-dev \
      libssh2-1-dev \
      libcurl4-openssl-dev \
      libbz2-dev liblzma-dev \
      libssl-dev \
      libfontconfig1-dev \
      libpcre2-dev \
      libpcre++-dev \
      libreadline-dev \
      bzip2 \
      r-base \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen

## Install eddelbuettel/littler, devtools and symlink the littler executables
RUN R -e "install.packages(c('littler', 'remotes'), dependencies = TRUE, repos = 'http://cran.rstudio.com/')" \
	&& ln -s /usr/local/lib/R/site-library/littler/bin/r /usr/local/bin/r \
	&& ln -s /usr/local/lib/R/site-library/littler/examples/*.r /usr/local/bin/

## Add additional deps for mostly building bioconductor packages.
## Also, separated for quicker rebuild if adding dependencies :)
RUN apt install -y \
      autoconf \
      automake \
      libtool \
      cmake \
      sqlite \
      pandoc \
      libgeos-dev \
      libopenblas-dev \
      liblapack-dev \
      libharfbuzz-dev \
      libfribidi-dev \
      libfreetype-dev \
      libfontconfig-dev \
      libgsl-dev \
      libhdf5-dev \
      libtiff-dev

## NB! - install prior packages from GH - not relevant for Ubuntu
## 22.11.06 - when this https://github.com/tidyverse/readxl/pull/708 gets updated to CRAN and propagated to tidyverse,
## move back to previous step or install just new version of tidyverse.
## Also BH does not compile in musl systems rn https://github.com/r-hub/r-minimal/issues/53
#RUN installGithub.r --deps TRUE \
#    tidyverse/readxl@1835c96 gaborcsardi/BH@fix/musl

## Install basic + tidyverse packages in R
# Needs a "haven" fix (somehow not linking proper LD libraries): https://github.com/tidyverse/haven/issues/363
RUN install2.r --ncpus 8 --skipinstalled --error -r http://cran.rstudio.com/ \
  BiocManager tidyverse plotly devtools languageserver renv knitr tinytex Rcpp \
  && r -e "tinytex::install_tinytex(force = TRUE)"

## Clean up temporary files
RUN apt autoremove -y && apt clean \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds

