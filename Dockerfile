FROM ubuntu:resolute@sha256:9559ceb7c21e528e233e8dff26a0fb2682f4094cce06176eeb075d87a22b31de as base

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
