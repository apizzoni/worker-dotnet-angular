FROM mcr.microsoft.com/dotnet/sdk:7.0

RUN curl -fsSL https://deb.nodesource.com/setup_19.x | sh

# Angular cli
RUN apt-get update && \
    apt-get install nodejs -y && \
    apt-get install ssh -y && \
    apt-get install nuget -y && \
    apt-get install lftp -y && \
    apt-get install openjdk-11-jre -y && \
    curl -L https://npmjs.org/install.sh | sh && \
    echo n | npm install -g @angular/cli@latest && \
    npm install -g yarn

# Kubernetes and helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    helm plugin install https://github.com/chartmuseum/helm-push.git && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/