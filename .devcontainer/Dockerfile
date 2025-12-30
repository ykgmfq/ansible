FROM mcr.microsoft.com/devcontainers/base:debian-13
COPY --from=quay.io/coreos/butane:release /usr/local/bin/butane /usr/local/bin/butane
RUN apt-get update && apt-get install -y ansible ansible-lint just ssh-askpass pre-commit && rm -rf /var/lib/apt/lists/*
