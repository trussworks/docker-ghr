
# CircleCI docker image to run within
FROM cimg/python:3.10.6
# Base image uses "circleci", to avoid using `sudo` run as root user
USER root

# install shellcheck
ARG SHELLCHECK_VERSION=0.7.1
ARG SHELLCHECK_SHA256SUM=64f17152d96d7ec261ad3086ed42d18232fcb65148b44571b564d688269d36c8
RUN set -ex && cd ~ \
    && curl -sSLO https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && [ $(sha256sum shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz | cut -f1 -d' ') = ${SHELLCHECK_SHA256SUM} ] \
    && tar xvfa shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz \
    && mv shellcheck-v${SHELLCHECK_VERSION}/shellcheck /usr/local/bin \
    && chown root:root /usr/local/bin/shellcheck \
    && rm -vrf shellcheck-v${SHELLCHECK_VERSION} shellcheck-v${SHELLCHECK_VERSION}.linux.x86_64.tar.xz

# install ghr
ARG GHR_VERSION=0.13.0
ARG GHR_SHA256SUM=c428627270ae26e206cb526cb8c7bdfba475dd278f6691ddaf863355adadfa13
RUN set -ex && cd ~ \
    && curl -sSLO https://github.com/tcnksm/ghr/releases/download/v${GHR_VERSION}/ghr_v${GHR_VERSION}_linux_amd64.tar.gz \
    && [ $(sha256sum ghr_v${GHR_VERSION}_linux_amd64.tar.gz | cut -f1 -d' ') = ${GHR_SHA256SUM} ] \
    && tar xzf ghr_v${GHR_VERSION}_linux_amd64.tar.gz \
    && mv ghr_v${GHR_VERSION}_linux_amd64/ghr /usr/local/bin \
    && rm -rf ghr_v${GHR_VERSION}_linux_amd64.tar.gz \
    && rm -rf ghr_v${GHR_VERSION}_linux_amd64

# install awscliv2, disable default pager (less)
ENV AWS_PAGER=""
ARG AWSCLI_VERSION=2.0.37
COPY sigs/awscliv2_pgp.key /tmp/awscliv2_pgp.key
RUN gpg --import /tmp/awscliv2_pgp.key
RUN set -ex && cd ~ \
    && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o awscliv2.zip \
    && curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip.sig" -o awscliv2.sig \
    && gpg --verify awscliv2.sig awscliv2.zip \
    && unzip awscliv2.zip \
    && ./aws/install --update \
    && aws --version \
    && rm -r awscliv2.zip awscliv2.sig aws

# apt-get all the things
# Notes:
# - Add all apt sources first
# - groff and less required by AWS CLI
ARG CACHE_APT
RUN set -ex && cd ~ \
    && apt-get update \
    && : Install apt packages \
    && apt-get -qq -y install --no-install-recommends apt-transport-https less groff lsb-release \
    && : Cleanup \
    && apt-get clean \
    && rm -vrf /var/lib/apt/lists/*

USER circleci
