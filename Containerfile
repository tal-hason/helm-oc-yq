FROM registry.access.redhat.com/ubi9:latest as builder

WORKDIR /tmp

USER root

ADD https://mirror.openshift.com/pub/openshift-v4/clients/helm/latest/helm-linux-amd64.tar.gz .
ADD https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz .
ADD https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 .
ADD https://mirror.openshift.com/pub/openshift-v4/clients/pipeline/latest/tkn-linux-amd64.tar.gz .
ADD https://github.com/jqlang/jq/releases/latest/download/jq-linux-amd64 .
ADD https://mirror.openshift.com/pub/rhacs/assets/latest/bin/Linux/roxctl .

RUN tar xvf helm-linux-amd64.tar.gz --no-same-owner && \
    tar xvf openshift-client-linux.tar.gz --no-same-owner && \
    tar xvf tkn-linux-amd64.tar.gz --no-same-owner && \
    rm -f *.tar.gz install-man-page.sh README.md LICENSE && \
    mv helm-linux-amd64 helm && \
    mv yq_linux_amd64 yq && \
    mv jq-linux-amd64 jq && \
    chmod +x yq && \
    chmod +x roxctl && \
    chmod +x jq


FROM registry.access.redhat.com/ubi9:latest

WORKDIR /home

COPY --from=builder --chown=1001:0 /tmp /usr/local/bin
# Copy Binarys to /usr/local/bin 
RUN dnf update -y && \
    dnf install git wget -y && \
    dnf clean all && \
    useradd git -m --home-dir /home/git --gid 0 -s /bin/bash --uid 1000 && \
    mkdir /home/git/.docker && touch /home/git/.gitconfig && touch /home/git/.git-credentials && \
    chown -R 1000:0  /home/git && \
    chmod -R 0775 /home/git && \
    PATH=$(echo $PATH:/home) && \
    echo $PATH && \
    ls -l

LABEL TOOLS="HELM, oc kubectl, yq, tkn, git, jq, roxctl"

USER 1000
CMD /bin/bash
