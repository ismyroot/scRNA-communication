# scRNA-communication：细胞通讯镜像（对应 singlecell_image_plan.md 中的 singlecell-communication）。
# 承载 CellChat、CommPath、CCPlotR 等系列工具依赖。
#
# 基础层：quay.io/1733295510/scrna-base:v1（Seurat + Quarto + TeX + scRNA-base 补包）
#
# CRAN 包版本与仓库根目录 docker_version.txt 对齐；Bioconductor 包由 BiocManager 按 R 4.4 / Bioc 3.19 解析。
#
# 构建示例：
#   cd /home/ubuntu/zhaoyiran/TOOL-Dockerfile/singlecell/scRNA-communication
#   docker build -t quay.io/1733295510/scrna-communication:v1 .

FROM quay.io/1733295510/scrna-base:v1

LABEL maintainer="1733295510 <1733295510@qq.com>"
LABEL org.opencontainers.image.title="scRNA-communication"
LABEL org.opencontainers.image.description="Cell-cell communication: CellChat, CommPath, CCPlotR, ComplexHeatmap, NMF, presto, ggalluvial, circlize."

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 第一次安装：CRAN（固定版本）— circlize / 桑基与 NMF 等
RUN R -e "remotes::install_version('circlize', '0.4.17', repos='https://cloud.r-project.org', upgrade='never')" && \
    R -e "remotes::install_version('ggalluvial', '0.12.5', repos='https://cloud.r-project.org', upgrade='never')" && \
    R -e "remotes::install_version('NMF', '0.28', repos='https://cloud.r-project.org', upgrade='never')"

# 第二次安装：Bioconductor（热图 / CellChat / presto / CommPath）+ CCPlotR（CRAN，依赖 CellChat 生态，放在 Bioc 之后）
RUN R -e "BiocManager::install(c(\
      'ComplexHeatmap', \
      'CellChat', \
      'presto', \
      'CommPath'\
    ), ask = FALSE, update = FALSE)" && \
    R -e "remotes::install_version('CCPlotR', '1.2.0', repos='https://cloud.r-project.org', upgrade='never')"

RUN R -e "\
  suppressPackageStartupMessages({\
    library(CellChat);\
    library(CommPath);\
    library(CCPlotR);\
    library(ComplexHeatmap);\
    library(presto);\
  });\
  cat('scRNA-communication OK: CellChat', as.character(packageVersion('CellChat')), \
      ' CommPath', as.character(packageVersion('CommPath')), '\n')\
"

WORKDIR /work
