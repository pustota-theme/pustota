# syntax=docker/dockerfile:1.7
# ========================================
# =               Warning!               =
# ========================================
# This is Github Action docker-based image.
# It is not intended for local development!
#
# You can find docs about how to setup your own Github Action here:
# https://dotenv-linter.readthedocs.io/en/latest/pages/integrations/github-actions.html
#
# It can still be used as a raw image for your own containers.
# See `action.yml` in case you want to learn more about Github Actions.
# See it live:
# https://github.com/wemake-services/dotenv-linter/actions
#
# This image is also available on Dockerhub:
# https://hub.docker.com/r/wemakeservices/dotenv-linter

FROM python:3.12.2-alpine

LABEL maintainer="sobolevn@wemake.services"
LABEL vendor="wemake.services"

ENV DOTENV_LINTER_VERSION='0.5.0'
ENV REVIEWDOG_VERSION='v0.17.2'

RUN apk add --no-cache bash git wget
RUN pip install "dotenv-linter==$DOTENV_LINTER_VERSION" \
  # Installing reviewdog to optionally comment on pull requests:
  && wget -O - -q 'https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh' \
  | sh -s -- -b /usr/local/bin/ "$REVIEWDOG_VERSION"

COPY ./scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]


# ---------------------------------------------------------------------------
# Additional syntax coverage below this point: a multi-stage build.
# ---------------------------------------------------------------------------

ARG PYTHON_VERSION=3.12.2
ARG BASE_IMAGE=python:${PYTHON_VERSION}-alpine
ARG REVIEWDOG_REPO="reviewdog/reviewdog"

FROM ${BASE_IMAGE} AS builder
ARG REVIEWDOG_REPO
ARG TARGETARCH
ENV PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PYTHONDONTWRITEBYTECODE=1
ENV POETRY_HOME /opt/poetry
WORKDIR /build
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

RUN --mount=type=cache,target=/root/.cache/pip \
    --mount=type=bind,source=requirements.txt,target=/tmp/requirements.txt \
    pip install --prefix=/install -r /tmp/requirements.txt

RUN <<EOF
set -eux
apk add --no-cache --virtual .build-deps gcc musl-dev
echo "building for ${TARGETARCH:-amd64} from ${REVIEWDOG_REPO}"
apk del .build-deps
EOF

COPY <<-"CONFIG" /build/dotenv-linter.toml
	[rules]
	ignore = ["LowercaseKey"]
CONFIG

ADD https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh /build/install-reviewdog.sh
ADD --checksum=sha256:0000000000000000000000000000000000000000000000000000000000000000 https://example.com/archive.tar.gz /build/vendor/
RUN ["sh", "/build/install-reviewdog.sh", "-b", "/usr/local/bin/"]

FROM scratch AS artifacts
COPY --from=builder /install /install

FROM ${BASE_IMAGE}
ARG PYTHON_VERSION
LABEL org.opencontainers.image.title="dotenv-linter" \
      org.opencontainers.image.version="${DOTENV_LINTER_VERSION:-0.5.0}" \
      org.opencontainers.image.source="https://github.com/wemake-services/dotenv-linter" \
      org.opencontainers.image.base.name="python:${PYTHON_VERSION}-alpine"

RUN addgroup -S linter && adduser -S -G linter linter
COPY --from=artifacts --chown=linter:linter /install /usr/local
COPY --from=builder --chmod=0644 /build/dotenv-linter.toml /etc/dotenv-linter.toml
COPY --link --chown=1000:1000 --chmod=755 ./scripts/ /opt/scripts/
COPY ["./scripts/entrypoint.sh", "./README.md", "/opt/"]

WORKDIR /github/workspace
VOLUME /github/workspace
VOLUME ["/var/cache/linter", "/tmp"]
EXPOSE 8080
EXPOSE 8443/tcp 5353/udp
USER linter:linter
STOPSIGNAL SIGTERM
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD dotenv-linter --version || exit 1
ONBUILD COPY .env /github/workspace/.env
ONBUILD RUN dotenv-linter /github/workspace/.env
ENTRYPOINT /opt/entrypoint.sh
CMD ["--help"]
