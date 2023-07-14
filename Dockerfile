FROM ubuntu:jammy as base


# Install dependencies
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    libcurl4 \
    screen \
    restic \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/* \
  && restic self-update

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