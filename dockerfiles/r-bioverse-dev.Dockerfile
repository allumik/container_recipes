## >>> "r-bioverse:dev" <<<
## allumik/r-bioverse:dev
## R bioinf focused development docker from base image
#### Other examples:
## https://github.com/r-hub/r-minimal/blob/master/Dockerfile

FROM allumik/r-bioverse:debian
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

## Install additional R packages
RUN install2.r --ncpus 8 --skipinstalled --error -r http://cran.rstudio.com/ \
  ggpubr ggvenn heatmaply viridis RColorBrewer glue magrittr pbkrtest \
  embed broom modelr mltools vip umap snow tictoc lme4 \
  Exact corrr statmod psych ranger remotes git2r \
  rmdformats doParallel tidymodels recipes reactable \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds

## Install Bioconductor packages
RUN installBioc.r --ncpus 8 --skipinstalled --error \
  DESeq2 edgeR limma sva rtracklayer biomaRt GenomicRanges \
  Seurat Rsamtools GenomicAlignments \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds

## Install packages from Git
RUN installGithub.r --deps \
  JiekaiLab/dior \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds