## >>> "r-bioverse" <<<
## allumik/r-bioverse
## R bioinf focused development docker from base Alpine linux.
#### Other examples:
## https://github.com/r-hub/r-minimal/blob/master/Dockerfile

FROM alpine:3.15.5
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

## Locale settings
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
## ensure installation is stripped
ENV _R_SHLIB_STRIP_=true
## Alpine does not detect timezone
ENV TZ=UTC

# add user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# setup workdir
WORKDIR /home/appuser
RUN chown appuser:appgroup -R /home/appuser

# add appuser binaries to path
# RUN echo "export PATH='/home/appuser/.local/bin/:$PATH'" >> /etc/profile
ENV PATH "$PATH:/home/appuser/.local/bin/"

## Base deps
ENV BASE_DEPS='''\
  libintl linux-headers gcc g++ gfortran make \
  wget \
  icu-dev \
  libxml2-dev \
  libjpeg-turbo \
  libpng-dev \
  libgit2-dev git \
  libssh2-dev \
  openssl-dev \
  pcre-dev pcre2-dev \
  readline-dev \
  libc6-compat \
  xz-dev \
  zlib-dev \
  bzip2-dev \
  curl-dev \
  R R-dev R-doc \
  '''

## Update Alpine and install the base deps
## https://pkgs.alpinelinux.org/packages
RUN apk upgrade --update \
  && apk add --no-cache --virtual persistent ${BASE_DEPS}

## Add additional deps for next steps
## Separated for quicker rebuild if adding deps :)
ENV ADDIT_DEPS='''\
  autoconf \
  automake \
  libtool \
  cmake \
  cairo \
  sqlite \
  geos-dev \
  openblas-dev \
  gsl-dev \
  hdf5-dev \
  lapack-dev \
  harfbuzz harfbuzz-dev \
  fribidi fribidi-dev \
  freetype freetype-dev \
  fontconfig fontconfig-dev \
  tiff tiff-dev \
  libx11 \
  lua \
  python3 py3-pip \
  '''

RUN apk add --no-cache --virtual addit ${ADDIT_DEPS}



# install further packages as appuser
USER appuser

## install tinytex
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh

# add tlmgr to path
# and install texlive packages
RUN \
  /home/appuser/.TinyTeX/bin/*/tlmgr path add \
  tlmgr install \
  preview \
  standalone \
  dvisvgm

## Set the default installer location for the appuser
ENV R_LIBS_USER="/home/appuser/R/library/"

## Install eddelbuettel/littler, devtools
RUN \
  mkdir -p "${R_LIBS_USER}" \
  && R -e "install.packages(c('littler', 'remotes'), dependencies = TRUE, repos = 'http://cran.rstudio.com/')"

## symlink the littr executables
RUN \
  mkdir -p /home/appuser/.local/bin/ \
	&& ln -s ${R_LIBS_USER}/littler/bin/r /home/appuser/.local/bin/r \
	&& ln -s ${R_LIBS_USER}/littler/examples/*.r /home/appuser/.local/bin/
  

## NB! - install prior packages from GH
## 22.11.06 - when this https://github.com/tidyverse/readxl/pull/708 gets updated to CRAN and propagated to tidyverse, 
## move back to previous step or install just new version of tidyverse.
## Also BH does not compile in musl systems rn https://github.com/r-hub/r-minimal/issues/53
RUN installGithub.r --deps TRUE \
    tidyverse/readxl@1835c96 gaborcsardi/BH@fix/musl

## Install basic + tidyverse packages in R
# Force tinytex instalation just to be sure that it gets linked to R
RUN install2.r --ncpus 8 --skipinstalled --error -r http://cran.rstudio.com/ \
  BiocManager haven tidyverse plotly devtools languageserver renv knitr httpgd \
  && r -e "tinytex::install_tinytex(force = T)" \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds

## setup python3, pip and install radian
RUN pip3 install --user radian