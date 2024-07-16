FROM mcr.microsoft.com/dotnet/sdk:8.0

# Install Node.js 21
RUN curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs

# Install additional packages
RUN apt-get update && \
    apt-get install -y ssh nuget lftp

# Update npm to the latest version
RUN npm install -g npm@latest

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
