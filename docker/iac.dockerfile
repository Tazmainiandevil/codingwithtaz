ARG IMAGE_VERSION=latest
ARG IMAGE_REPO=alpine

FROM ${IMAGE_REPO}:${IMAGE_VERSION} AS installer-env

ARG TERRAFORM_VERSION=0.12.26
ARG TERRAFORM_PACKAGE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ARG TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_PACKAGE}

ARG POWERSHEL_VERSION=7.0.1
ARG POWERSHELL_PACKAGE=powershell-${POWERSHEL_VERSION}-linux-alpine-x64.tar.gz
ARG POWERSHLL_DOWNLOAD_PACKAGE=powershell.tar.gz
ARG POWERSHELL_URL=https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHEL_VERSION}/${POWERSHELL_PACKAGE}

# Install packages
RUN apk upgrade --update && \
    apk add --no-cache bash wget curl python3 libffi openssl

# Get Terraform
RUN wget --quiet ${TERRAFORM_URL} && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin

# Get PowerShell Core
RUN curl -L ${POWERSHELL_URL} -o /tmp/${POWERSHLL_DOWNLOAD_PACKAGE}&& \
    mkdir -p /opt/microsoft/powershell/7 && \
    tar zxf /tmp/${POWERSHLL_DOWNLOAD_PACKAGE} -C /opt/microsoft/powershell/7 && \
    chmod +x /opt/microsoft/powershell/7/pwsh

# New stage to remove tar.gz layers from the final image
FROM ${IMAGE_REPO}:${IMAGE_VERSION}

# Copy only the files we need from the previous stage
COPY --from=installer-env ["/usr/bin/terraform", "/usr/bin/terraform"]
COPY --from=installer-env ["/opt/microsoft/powershell/7", "/opt/microsoft/powershell/7"]
RUN ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh

ENV ANSIBLE_VERSION=2.9.9
ENV ALPINE_ANSIBLE_VERSION=2.9.9-r0
ENV WHEEL_VERSION=0.30.0
ENV APK_ADD="bash py3-pip ansible=${ALPINE_ANSIBLE_VERSION}"
ENV APK_POWERSHELL="ca-certificates less ncurses-terminfo-base krb5-libs libgcc libintl libssl1.1 libstdc++ tzdata userspace-rcu zlib icu-libs"

# Install core packages
RUN apk upgrade --update && \
    apk add --no-cache ${APK_ADD} ${APK_POWERSHELL} && \
    apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache lttng-ust

# Install Ansible and other packages
RUN python3 -m pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir wheel==${WHEEL_VERSION} && \
    pip install --no-cache-dir ansible[azure]==${ANSIBLE_VERSION} mitogen && \
    pip install --no-cache-dir netaddr xmltodict openshift

CMD tail -f /dev/null
