FROM debian:12-slim

WORKDIR /home/default

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG PYTHON_VERSION=3.11.7
ARG SKAFFOLD_VERSION=2.9.0
ARG KUBERNETES_VERSION=1.27.3
ARG HELM_VERSION=3.13.3
ARG SOPS_VERSION=3.8.1
ARG TASK_VERSION=3.31.0
ARG HELM_SECRETS_VERSION=4.4.2
ARG NODE_VERSION=20.8.0
ARG YARN_VERSION=1.22.21
ARG RCLONE_VERSION=1.62.2
ARG ANSIBLE_VERSION=9.1.0
ARG ANSIBLE_LINT_VERSION=6.22.1
ARG TARGETARCH
ARG GID=1001
ARG UID=1001

ENV HOME=/home/default

# Install tools
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    jq \
    lsb-release \
    make \
    unzip \
    wget \
    git \
    ssh \
    zip

# Install asdf
ENV ASDF_DIR=/home/default/.asdf
ENV PATH=$ASDF_DIR/bin:$ASDF_DIR/shims:$PATH
ENV ASDF_DEFAULT_TOOL_VERSIONS_FILENAME=../../home/default/.tool-versions
RUN git clone https://github.com/asdf-vm/asdf.git /home/default/.asdf --branch v0.14.0

# Install nodenv and Node.js
RUN asdf plugin add nodejs && \
    asdf install nodejs $NODE_VERSION && \
    asdf global nodejs $NODE_VERSION

ENV COREPACK_ROOT=$HOME/.corepack
ENV PATH=$COREPACK_ROOT:$PATH
RUN mkdir $COREPACK_ROOT && \
    corepack enable --install-directory $COREPACK_ROOT && \
    corepack prepare yarn@${YARN_VERSION} --activate && \
    asdf reshim nodejs

# Install Python
ENV PYTHONUNBUFFERED=1
ENV PATH=$PATH:$PYENV_ROOT/shims:$PYENV_ROOT/bin
RUN apt-get update && \
    apt-get install --no-install-recommends -y make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev && \
    asdf plugin add python && \
    asdf install python $PYTHON_VERSION && \
    asdf global python $PYTHON_VERSION

# Install Ansible and ansible-lint
RUN pip install \
    ansible==$ANSIBLE_VERSION \
    ansible-lint==$ANSIBLE_LINT_VERSION

# Install Docker
ENV DOCKER_CONFIG=$HOME/.docker
ENV DEBIAN_FRONTEND=noninteractive

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/debian \
        $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get -y install --no-install-recommends docker-ce-cli && \
    mkdir -p $DOCKER_CONFIG/cli-plugins && \
    curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-$(if [ "${TARGETARCH}" = "arm64" ]; then echo "aarch64"; elif [ "${TARGETARCH}" = "amd64" ]; then echo "x86_64"; else echo "${TARGETARCH}"; fi) -o $DOCKER_CONFIG/cli-plugins/docker-compose && \
    curl -SL https://github.com/docker/buildx/releases/download/v0.12.0/buildx-v0.12.0.linux-$TARGETARCH -o $DOCKER_CONFIG/cli-plugins/docker-buildx && \
    chmod a+x $DOCKER_CONFIG/cli-plugins/*

# Install Skaffold
RUN asdf plugin add skaffold && \
    asdf install skaffold $SKAFFOLD_VERSION && \
    asdf global skaffold $SKAFFOLD_VERSION

# Install Kubernetes
RUN asdf plugin add kubectl && \
    asdf install kubectl $KUBERNETES_VERSION && \
    asdf global kubectl $KUBERNETES_VERSION

# Install Helm
RUN asdf plugin add helm && \
    asdf install helm $HELM_VERSION && \
    asdf global helm $HELM_VERSION && \
    helm plugin install https://github.com/jkroepke/helm-secrets --version v$HELM_SECRETS_VERSION

# Install Task
RUN asdf plugin add task && \
    asdf install task $TASK_VERSION && \
    asdf global task $TASK_VERSION

# Install Terraform
RUN asdf plugin add terraform && \
    asdf install terraform latest && \
    asdf global terraform $(asdf latest terraform)

# Install SOPS
RUN asdf plugin add sops && \
    asdf install sops $SOPS_VERSION && \
    asdf global sops $SOPS_VERSION

# Install rclone
RUN asdf plugin add rclone && \
    asdf install rclone $RCLONE_VERSION && \
    asdf global rclone $RCLONE_VERSION

# Install additional tools
RUN apt-get install --no-install-recommends -y \
    sshpass \
    pv

# Install PostgreSQL client
ENV POSTGRES_SKIP_INITDB=true
RUN asdf plugin add postgres && \
    asdf install postgres latest && \
    asdf global postgres $(asdf latest postgres)

# Install Trunk
RUN curl https://get.trunk.io -fsSL | bash -s -- -y && \
    trunk

# Create a user called "default"
RUN groupadd --gid $GID default || true \
    && useradd --uid $UID --gid $GID --shell /bin/bash --create-home default

RUN mkdir -p /run/docker

# Set permissions
RUN chmod 755 /etc && \
    chmod 755 /run && \
    chmod 755 /var && \
    chmod 755 /var/run && \
    chmod 755 /opt && \
    chmod 755 /tmp && \
    chown $UID:$GID -R /home/default && \
    chown $UID:$GID -R /var && \
    chown $UID:$GID -R /run && \
    chown $UID:$GID -R /var/run && \
    chown $UID:$GID -R /opt/ && \
    chown $UID:$GID -R /tmp/ && \
    chown $UID:$GID /usr/local/bin/* && \
    chmod +x /usr/local/bin/*

# Smoke tests
USER default
RUN ansible --version && \
    ansible-lint --version && \
    node --version && \
    docker --version && \
    docker compose && \
    docker buildx && \
    skaffold version && \
    kubectl version --short --client -o yaml && \
    helm version --short && \
    task --version && \
    terraform --version && \
    sops --version && \
    psql --version && \
    trunk --version

USER root

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER default

RUN mkdir $HOME/.ssh && \
    chmod 700 $HOME/.ssh
RUN mkdir $HOME/.kube && \
    chmod 755 $HOME/.kube

CMD [ "sleep", "14400" ]

LABEL org.opencontainers.image.source=https://github.com/echohello-dev/pipeline-toolkits
LABEL org.opencontainers.image.description="A container image for running CI/CD pipelines."
LABEL org.opencontainers.image.licenses=MIT