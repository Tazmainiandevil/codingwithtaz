ARG IMAGE_VERSION=latest
ARG IMAGE_REPO=alpine

FROM ${IMAGE_REPO}:${IMAGE_VERSION} AS installer-env

ARG TERRAFORM_VERSION=0.12.26
ARG TERRAFORM_PACKAGE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ARG TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_PACKAGE}

# Install packages
RUN apk upgrade --update && \
    apk add --no-cache bash wget

# Get Terraform
RUN wget --quiet ${TERRAFORM_URL} && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin

# New stage to remove tar.gz layers from the final image
FROM ${IMAGE_REPO}:${IMAGE_VERSION}

# Copy only the files we need from the previous stage
COPY --from=installer-env ["/usr/bin/terraform", "/usr/bin/terraform"]

ENV ANSIBLE_VERSION=2.9.9
ENV ALPINE_ANSIBLE_VERSION=2.9.9-r0
ENV WHEEL_VERSION=0.30.0
ENV APK_ADD="bash py3-pip ansible=${ALPINE_ANSIBLE_VERSION}"

# Install core packages
RUN apk upgrade --update && \
    apk add --no-cache ${APK_ADD}

# Install Ansible and other packages
RUN python3 -m pip install --upgrade pip && \
    pip install wheel==${WHEEL_VERSION} && \
    pip install ansible[azure]==${ANSIBLE_VERSION} mitogen && \
    pip install netaddr xmltodict openshift

CMD tail -f /dev/null
