## >>> "r-ml" <<<
## allumik/r-ml
## R bioinf focused development docker with radian terminal
## to utilize GPU's, run with `--gpus all` flag

FROM rocker/ml-verse:4.2
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

# default user: "rstudio"
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV DISABLE_AUTH=true

## install extra packages
RUN install2.r --error -n 8 -s \
      ggpubr ggvenn modelr heatmaply viridis RColorBrewer \
      embed broom devEMF mltools vip showtext umap writexl \
      Exact corrr statmod tictoc psych ranger remotes git2r \
      xgboost rmdformats \
    && rm -rf /tmp/downloaded_packages /tmp/*.rds