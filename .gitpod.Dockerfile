# FROM gitpod/workspace-full

# USER gitpod

# # Install Miniconda
# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
#     bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda && \
#     rm Miniconda3-latest-Linux-x86_64.sh

# # Initialize Conda
# RUN $HOME/miniconda/bin/conda init bash

FROM gitpod/workspace-full:latest

# Set Conda variables (optional safety)
ENV MAMBA_ROOT_PREFIX=/opt/conda \
    PATH=/opt/conda/bin:$PATH \
    SHELL=/bin/bash

# Install micromamba
RUN curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj -C /usr/local/bin --strip-components=1 bin/micromamba

# Create environment
COPY environment.yml /tmp/environment.yml
RUN micromamba create -y -n denovo_assembly -f /tmp/environment.yml && \
    echo "micromamba activate denovo_assembly" >> ~/.bashrc && \
    micromamba clean --all --yes

# Set working directory
WORKDIR /workspace



