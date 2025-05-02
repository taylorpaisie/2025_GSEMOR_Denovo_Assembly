# FROM gitpod/workspace-full

# USER gitpod

# # Install Miniconda
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
#     bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda && \
#     rm Miniconda3-latest-Linux-x86_64.sh

# # Initialize Conda
# RUN $HOME/miniconda/bin/conda init bash

FROM mambaorg/micromamba:latest

# Set up workspace
WORKDIR /workspace

# Copy your environment file
COPY environment.yml .

# Create the environment during image build
RUN micromamba create -y -n denovo_assembly -f environment.yml && \
    micromamba clean --all --yes

# Automatically activate it in every shell
RUN echo "micromamba activate denovo_assembly" >> ~/.bashrc
