FROM mcr.microsoft.com/dotnet/sdk:5.0

# Angular cli
RUN apt-get update && \
    apt-get install nodejs -y && \
    apt-get install yarn -y && \
    curl -L https://npmjs.org/install.sh | sh && \
    echo n | npm install -g @angular/cli@12

# Kubernetes and helm
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ 
