FROM mcr.microsoft.com/dotnet/sdk:8.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# ---- Versions (pin where sensible) ----
ARG NODE_MAJOR=20
ARG NODE_VERSION=20.11.1-1nodesource1
ARG NPM_VERSION=10.2.4
# Choose kubelogin version (pin it for reproducibility)
ARG KUBELOGIN_VERSION=0.0.34
# Choose kubectl version (pin it if you want). If empty, uses latest stable.
ARG KUBECTL_VERSION=""

# ---- Base packages needed for installs (and useful in CI) ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    unzip \
    git \
    openssh-client \
    gnupg \
    lsb-release \
    apt-transport-https \
    jq \
    ssh \
    nuget \
    lftp \
  && rm -rf /var/lib/apt/lists/*

# ---- Install Node.js v20.11.1 + npm 10.2.4 ----
RUN curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" | bash - \
  && apt-get update \
  && apt-get install -y --no-install-recommends nodejs=${NODE_VERSION} \
  && npm install -g npm@${NPM_VERSION} \
  && rm -rf /var/lib/apt/lists/*

# ---- Install Angular CLI + yarn ----
RUN npm install -g @angular/cli@latest yarn

# ---- Install Azure CLI (official Microsoft apt repo) ----
RUN mkdir -p /etc/apt/keyrings \
  && curl -sLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg \
  && chmod go+r /etc/apt/keyrings/microsoft.gpg \
  && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
     > /etc/apt/sources.list.d/azure-cli.list \
  && apt-get update \
  && apt-get install -y --no-install-recommends azure-cli \
  && rm -rf /var/lib/apt/lists/*

# ---- Install Helm + helm-push plugin ----
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 -o get_helm.sh \
  && chmod 700 get_helm.sh \
  && ./get_helm.sh \
  && rm -f get_helm.sh \
  && helm plugin install https://github.com/chartmuseum/helm-push.git

# ---- Install kubectl ----
RUN if [ -z "$KUBECTL_VERSION" ]; then \
      KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"; \
    fi \
  && curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl" \
  && install -m 0755 kubectl /usr/local/bin/kubectl \
  && rm -f kubectl

# ---- Install kubelogin (required for AKS Entra/AAD exec auth) ----
RUN curl -fsSLO "https://github.com/Azure/kubelogin/releases/download/v${KUBELOGIN_VERSION}/kubelogin-linux-amd64.zip" \
  && unzip -q kubelogin-linux-amd64.zip -d /tmp/kubelogin \
  && install -m 0755 /tmp/kubelogin/bin/linux_amd64/kubelogin /usr/local/bin/kubelogin \
  && rm -rf /tmp/kubelogin kubelogin-linux-amd64.zip

# ---- Quick sanity check (optional but helpful to fail fast in build) ----
RUN az version \
  && kubectl version --client=true \
  && kubelogin --version \
  && helm version

# Default workdir
WORKDIR /work