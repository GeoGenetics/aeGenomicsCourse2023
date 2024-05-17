FROM ubuntu

RUN apt-get update \
    && apt-get install -y \
    curl \
    git \
    golang \
    sudo \
    vim \
    wget \
    stress \
    libgsl-dev \
    libeigen3-dev \
    libcurl4-openssl-dev \
    libbz2-dev \
    zlib1g-dev \
    liblzma-dev \
    time \
    locales \
    htop \
    tmux \
    datamash \
    && rm -rf /var/lib/apt/lists/*

ARG USER=coder
RUN useradd --groups sudo --no-create-home --shell /bin/bash ${USER} \
    && echo "${USER} ALL=(ALL) NOPASSWD:ALL" >/etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}
USER ${USER}
RUN sudo locale-gen en_US.UTF-8
WORKDIR /home/${USER}