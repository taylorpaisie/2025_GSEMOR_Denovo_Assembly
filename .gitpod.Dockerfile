# FROM gitpod/workspace-full

# USER gitpod

# # Install Miniconda
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
#     bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda && \
#     rm Miniconda3-latest-Linux-x86_64.sh

# # Initialize Conda
# RUN $HOME/miniconda/bin/conda init bash

FROM mambaorg/micromamba:latest

# Set up shell for Gitpod and Conda
ENV SHELL=/bin/bash \
    MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:$PATH

# Set working directory
WORKDIR /workspace

# Copy the environment file into the image
COPY environment.yml /tmp/environment.yml

# Create the environment during image build
RUN micromamba create -y -n denovo_assembly -f /tmp/environment.yml && \
    echo "micromamba activate denovo_assembly" >> ~/.bashrc && \
    micromamba clean --all --yes

# Default to bash
SHELL ["/bin/bash", "-c"]

