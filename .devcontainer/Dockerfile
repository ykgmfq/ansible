# rbw isn't in trixie, and forky's build needs a newer libc.
FROM docker.io/library/rust:1-slim-trixie AS rbw
RUN cargo install --locked --root=/opt/rbw rbw@1.15.0

FROM mcr.microsoft.com/devcontainers/base:debian-13
LABEL org.opencontainers.image.title="ansible"
LABEL org.opencontainers.image.vendor="Dennis M. Pöpperl"
LABEL org.opencontainers.image.source="https://github.com/ykgmfq/ansible"
LABEL org.opencontainers.image.description="Devcontainer with Ansible, ansible-lint, Butane, rbw, qrencode and just"
COPY --from=quay.io/coreos/butane:release /usr/local/bin/butane /usr/local/bin/butane
COPY --from=rbw /opt/rbw/bin/rbw /opt/rbw/bin/rbw-agent /usr/local/bin/
# Debian's packaged ansible-core is too old for newer target Pythons (setup module crashed in dataclasses).
# uv downloads the newest Python (only-managed ignores Debian's), so the controller doesn't depend on it.
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv
COPY requirements.txt /tmp/requirements.txt
ENV UV_PYTHON_PREFERENCE=only-managed UV_PYTHON_INSTALL_DIR=/opt/uv/python
RUN apt-get update && apt-get install -y just ssh-askpass pre-commit markdownlint nftables python3-jinja2 python3-yaml pinentry-curses qrencode && rm -rf /var/lib/apt/lists/* \
 && uv venv /opt/ansible && uv pip install --python /opt/ansible -r /tmp/requirements.txt \
 && ln -s /opt/ansible/bin/ansible* /usr/local/bin/ && rm /tmp/requirements.txt
