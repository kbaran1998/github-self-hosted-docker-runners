# ─── base ────────────────────────────────────────────────────────────────────
FROM ubuntu:24.04 AS base

ARG RUNNER_VERSION

# system dependencies and common CI tools
RUN apt-get update -y && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        wget \
        git \
        jq \
        unzip \
        zip \
        tar \
        gnupg \
        lsb-release \
        software-properties-common \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3 \
        python3-venv \
        python3-dev \
        python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI + Buildx + Compose plugin
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
        -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
        > /etc/apt/sources.list.d/docker.list \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        docker-ce-cli \
        docker-buildx-plugin \
        docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
        https://cli.github.com/packages stable main" \
        > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# GitHub Actions runner
RUN useradd -m docker \
    && mkdir -p /home/docker/actions-runner \
    && cd /home/docker/actions-runner \
    && curl -O -L \
        "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    && tar xzf "./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    && rm "./actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    && chown -R docker /home/docker \
    && /home/docker/actions-runner/bin/installdependencies.sh

# ─── repo runner ─────────────────────────────────────────────────────────────
FROM base AS repo-runner
COPY repo-runner/run.sh /run.sh
RUN chmod +x /run.sh
USER docker
ENTRYPOINT ["/run.sh"]

# ─── org runner ──────────────────────────────────────────────────────────────
FROM base AS org-runner
COPY org-runner/run.sh /run.sh
RUN chmod +x /run.sh
USER docker
ENTRYPOINT ["/run.sh"]
