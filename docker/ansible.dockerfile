ARG IMAGE_VERSION=latest
ARG IMAGE_REPO=alpine

FROM ${IMAGE_REPO}:${IMAGE_VERSION}

ENV ANSIBLE_VERSION=2.9.9
ENV ALPINE_ANSIBLE_VERSION=2.9.9-r0
ENV WHEEL_VERSION=0.30.0
ENV APK_ADD="bash py3-pip ansible=${ALPINE_ANSIBLE_VERSION}"

# Install core libs
RUN apk upgrade --update && \
    apk add --no-cache ${APK_ADD}

# Install Ansible 
RUN python3 -m pip install --upgrade pip && \
    pip install wheel==${WHEEL_VERSION} && \
    pip install ansible[azure]==${ANSIBLE_VERSION} mitogen && \
    pip install netaddr xmltodict openshift

CMD tail -f /dev/null
