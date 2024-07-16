FROM mcr.microsoft.com/dotnet/sdk:8.0

# Install Node.js v20.11.1
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs=20.11.1-1nodesource1

# Install npm 10.2.4
RUN npm install -g npm@10.2.4

# Install additional packages
RUN apt-get update && \
    apt-get install -y ssh nuget lftp

# Install Angular CLI and yarn
RUN npm install -g @angular/cli@latest yarn

# Install Kubernetes and Helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    helm plugin install https://github.com/chartmuseum/helm-push.git && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/
