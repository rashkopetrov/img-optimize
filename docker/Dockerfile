FROM debian:stretch-slim

COPY ../scripts/install-dependencies.sh /root/install-dependencies.sh
RUN chmod +x /root/install-dependencies.sh && \
	/root/install-dependencies.sh && \
	rm /root/install-dependencies.sh

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY optimize.sh /usr/local/bin/optimize.sh
RUN chmod +x /usr/local/bin/optimize.sh

WORKDIR /tmp

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
