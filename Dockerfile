FROM ubuntu:bionic as base
LABEL maintainer="tomasz@chorwat.pl"
LABEL project="https://github.com/tchorwat/bedrock-in-docker"

# Install dependencies
RUN apt-get update \
  && apt-get install -y \
    gosu \
    libcurl4 \
    screen \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Copy projects scripts
COPY ./scripts /scripts

# Create directory structures
RUN useradd -m -d /bedrock bedrock \
  && mkdir /downloads \
  && mkdir /backups \
  && mkdir /bedrock/worlds \
  && chown -R bedrock:bedrock /bedrock \
  && chmod -R 700 /scripts

ENV BEDROCK_IN_DOCKER_TERM_MIN="1"
ENV BEDROCK_IN_DOCKER_FORCE_RESTORE="0"
ENV BEDROCK_IN_DOCKER_FORCE_1_MIN_RESTART="0"
ENV BEDROCK_IN_DOCKER_RESTART_TIME_UTC="03:00"

WORKDIR /bedrock
USER root
EXPOSE 19132/udp 19133/udp
ENTRYPOINT ["/scripts/entrypoint.sh"]
CMD ["bedrock_server"]
