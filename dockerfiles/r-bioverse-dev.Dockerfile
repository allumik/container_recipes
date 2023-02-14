## >>> "r-bioverse:dev" <<<
## allumik/r-bioverse:dev
## R bioinf focused development docker from base Alpine linux with radian terminal.
## Although based on Alpine, this environment is a superset of all others for development.
## So it is fat.
#### Other examples:
## https://github.com/r-hub/r-minimal/blob/master/Dockerfile

FROM allumik/r-bioverse
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"


## Install additional R packages
RUN install2.r --ncpus 8 --skipinstalled --error -r http://cran.rstudio.com/ \
  ggpubr ggvenn heatmaply viridis RColorBrewer glue magrittr \
  embed broom modelr mltools vip umap snow tictoc lme4 \
  Exact corrr statmod psych ranger remotes git2r \
  rmdformats doParallel tidymodels recipes reactable 

## Install Bioconductor packages
RUN installBioc.r --ncpus 8 --skipinstalled --error \
  DESeq2 edgeR limma sva rtracklayer biomaRt GenomicRanges \
  Seurat Rsamtools GenomicAlignments

## Install packages from Git and clean up temporary files
RUN installGithub.r --deps \
  JiekaiLab/dior \
  && rm -rf /tmp/downloaded_packages /tmp/*.rds