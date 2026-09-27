ARG DEBIAN_TAG
# rbw isn't in trixie, and forky's build needs a newer libc.
FROM docker.io/library/rust:1-slim-trixie AS rbw
RUN cargo install --locked --root=/opt/rbw rbw@1.15.0

FROM mcr.microsoft.com/devcontainers/base:debian-${DEBIAN_TAG}
LABEL org.opencontainers.image.source="https://github.com/ykgmfq/ansible"
LABEL org.opencontainers.image.description="Devcontainer with Ansible, ansible-lint, Butane, rbw and just"
COPY --from=quay.io/coreos/butane:release /usr/local/bin/butane /usr/local/bin/butane
COPY --from=rbw /opt/rbw/bin/rbw /opt/rbw/bin/rbw-agent /usr/local/bin/
RUN apt-get update && apt-get install -y ansible ansible-lint just ssh-askpass pre-commit markdownlint nftables pinentry-curses && rm -rf /var/lib/apt/lists/*
