FROM ubuntu:noble@sha256:c4a8d5503dfb2a3eb8ab5f807da5bc69a85730fb49b5cfca2330194ebcc41c7b as base

# Install dependencies
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
  ca-certificates \
  jq \
  libcurl4 \
  screen \
  restic \
  unzip \
  vim \
  wget \
  && rm -rf /var/lib/apt/lists/*

# Copy projects scripts
COPY ./scripts /scripts

# Create directory structures
RUN useradd -m -d /bedrock bedrock \
  && mkdir /downloads \
  && chown bedrock:bedrock /downloads \
  && mkdir /bedrock/worlds\
  && chown -R bedrock:bedrock /bedrock \
  && chmod -R 755 /scripts \
  && ln -s /scripts/connect-to-console.sh /usr/local/bin/console

ENV BEDROCK_IN_DOCKER_TERM_MIN="1"
ENV BEDROCK_IN_DOCKER_FORCE_1_MIN_RESTART="0"
ENV BEDROCK_IN_DOCKER_RESTART_TIME_UTC="03:00"

VOLUME /downloads
VOLUME /bedrock

WORKDIR /bedrock
USER bedrock
ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["bedrock_server"]

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD ps -C bedrock_server

LABEL org.opencontainers.image.source=https://github.com/JohnStrunk/bedrock-in-docker
LABEL org.opencontainers.image.description="Minecraft Bedrock Server in Docker"
LABEL org.opencontainers.image.licenses=MIT
