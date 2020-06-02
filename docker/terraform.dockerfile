ARG IMAGE_VERSION=latest
ARG IMAGE_REPO=alpine

FROM ${IMAGE_REPO}:${IMAGE_VERSION} AS installer-env

ARG TERRAFORM_VERSION=0.12.26
ARG TERRAFORM_PACKAGE=terraform_${TERRAFORM_VERSION}_linux_amd64.zip
ARG TERRAFORM_URL=https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_PACKAGE}

# Install packages to get terraform
RUN apk upgrade --update && \
    apk add --no-cache wget

RUN wget --quiet ${TERRAFORM_URL} && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    mv terraform /usr/bin

# New stage to remove tar.gz layers from the final image
FROM ${IMAGE_REPO}:${IMAGE_VERSION}

# Copy only the files we need from the previous stage
COPY --from=installer-env ["/usr/bin/terraform", "/usr/bin/terraform"]

# Install additional packages
RUN apk upgrade --update && \
    apk add --no-cache bash 

CMD tail -f /dev/null
