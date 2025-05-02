# FROM gitpod/workspace-full

# USER gitpod

# # Install Miniconda
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
#     bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda && \
#     rm Miniconda3-latest-Linux-x86_64.sh

# # Initialize Conda
# RUN $HOME/miniconda/bin/conda init bash

FROM mambaorg/micromamba:latest

# Set shell and env
ENV SHELL=/bin/bash \
    MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:$PATH

# Switch to root to install system packages
USER root

# Install sudo and core tools
RUN apt-get update && \
    apt-get install -y sudo git curl wget build-essential && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Restore to Gitpod user (gitpod)
USER gitpod

# Set working directory
WORKDIR /workspace

# Copy Conda env file
COPY environment.yml /tmp/environment.yml

# Create Conda environment
RUN micromamba create -y -n denovo_assembly -f /tmp/environment.yml && \
    echo "micromamba activate denovo_assembly" >> ~/.bashrc && \
    micromamba clean --all --yes

# Set default shell
SHELL ["/bin/bash", "-c"]


