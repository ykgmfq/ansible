ARG DEBIAN_TAG
FROM mcr.microsoft.com/devcontainers/base:debian-${DEBIAN_TAG}
LABEL org.opencontainers.image.source="https://github.com/ykgmfq/ansible"
LABEL org.opencontainers.image.description="Devcontainer with Ansible, ansible-lint, Butane and just"
COPY --from=quay.io/coreos/butane:release /usr/local/bin/butane /usr/local/bin/butane
RUN apt-get update && apt-get install -y ansible ansible-lint just ssh-askpass pre-commit markdownlint && rm -rf /var/lib/apt/lists/*
