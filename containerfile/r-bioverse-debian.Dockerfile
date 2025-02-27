## >>> "r-bioverse" <<<
## allumik/r-bioverse:fat
## R bioinf focused development docker based on Ubuntu.

FROM debian:bullseye-slim
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

# Set the locale
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
## ensure installation is stripped
ENV DEBIAN_FRONTEND=noninteractive
## set timezone to be UTC
ENV TZ=UTC
## Set the default installer location for the appuser
ENV R_LIBS_USER="/home/appuser/R/library/"

## add repo with newer version of R
RUN apt update -q -q && apt install -y gnupg2 \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
  && echo 'deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/' >> /etc/apt/sources.list

## Update debian (unnecessary when previously updated) and install the deps
RUN apt update -q -q && apt upgrade -y \
    && apt install -y \
      locales \
      build-essential \
      gfortran \
      make \
      wget \
      bzip2 \
      r-base r-base-dev \
      python3 python3-pip \
      autoconf \
      automake \
      libtool \
      cmake \
      sqlite3 \
      pandoc \
      libc6 libc6-dev \
      ca-certificates \
      libopenblas-base \
      libxml2-dev \
      libjpeg62-turbo-dev \
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
      libgeos-dev \
      libopenblas-dev \
      liblapack-dev \
      libharfbuzz-dev \
      libfribidi-dev \
      libfreetype-dev \
      libfontconfig-dev \
      libgsl-dev \
      libhdf5-dev \
      libtiff-dev \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && apt autoremove -y \
    && apt clean

# install further stuff as appuser
RUN useradd --user-group --system --create-home --no-log-init appuser
USER appuser
## Set the default installer location for the appuser
ENV R_LIBS_USER="/home/appuser/R/library/"
ENV PATH=$PATH:/home/appuser/.local/bin


## Install eddelbuettel/littler, devtools and symlink the littler executables
RUN mkdir -p "${R_LIBS_USER}" \
  && R -e "install.packages(c('littler', 'remotes'), dependencies = TRUE, repos = 'http://cran.rstudio.com/')" \
  && mkdir -p /home/appuser/.local/bin/ \
	&& ln -s ${R_LIBS_USER}/littler/bin/r /home/appuser/.local/bin/r \
	&& ln -s ${R_LIBS_USER}/littler/examples/*.r /home/appuser/.local/bin/

## Install utility + tidyverse + bioconductor packages in R
RUN install2.r --ncpus 8 --skipinstalled --error -r http://cran.rstudio.com/ \
  remotes BiocManager tidyverse plotly devtools languageserver renv knitr tinytex Rcpp httpgd \
  && r -e "tinytex::install_tinytex(force = TRUE)" \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds


## setup python3, pip and install radian
RUN pip3 install --user radian