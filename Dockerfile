FROM kannibalox/pyrosimple:2.14.2 AS builder

FROM python:3.13-slim

# Update
RUN apt-get update \
 && apt-get upgrade -y

# Install cron and jq
RUN apt-get install -y --no-install-recommends cron curl jq \
 && rm -rf /var/lib/apt/lists/*

# Copy files into container
COPY cron_trump_search /etc/cron.d/cron_trump_search
COPY trump_search.sh /usr/local/bin/trump_search.sh
COPY entrypoint.sh /entrypoint.sh

# Create files
RUN touch /var/log/cron.log

# Create a non-root user and group
RUN groupadd -r tinyg && useradd -r -g tinyg tinyu

# Correct permissions
RUN chmod 0550 /usr/local/bin/trump_search.sh \
 && chgrp tinyg /usr/local/bin/trump_search.sh \
 && chmod 0400 /etc/cron.d/cron_trump_search \
 && chmod 0500 /entrypoint.sh

LABEL org.opencontainers.image.description="Container to search for trumped movies, delete them, and search for new copy"

# Start
CMD ["/entrypoint.sh"]