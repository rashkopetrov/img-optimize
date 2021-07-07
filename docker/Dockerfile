FROM debian:stretch-slim

COPY ./docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY ./scripts/optimize.sh /usr/local/bin/optimize

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        bc \
        curl \
        jpegoptim \
        optipng \
        webp \
        ca-certificates && \
    curl -L -o /usr/local/bin/avif \
        https://github.com/Kagami/go-avif/releases/download/v0.1.0/avif-linux-x64 && \
    apt-get purge -y \
        curl \
        ca-certificates && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/log/* && \
    chmod +x /usr/local/bin/avif && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/optimize && \
    mkdir /workdir

WORKDIR /workdir

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
