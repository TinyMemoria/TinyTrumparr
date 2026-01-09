FROM kannibalox/pyrosimple:2.14.2 AS builder

# Fix vulnerabilities in image
COPY requirements.txt /tmp/requirements.txt

RUN /venv/bin/python -m pip install -U -r /tmp/requirements.txt

FROM python:3.13-slim

# Update
RUN apt-get update \
 && apt-get upgrade -y

# Install curl and jq
RUN apt-get install -y --no-install-recommends curl jq \
 && rm -rf /var/lib/apt/lists/*

# Copy files into container
COPY --from=builder /venv /venv
COPY trump_search.sh /usr/local/bin/trump_search.sh
COPY entrypoint.sh /entrypoint.sh

# Create a non-root user and group
RUN groupadd -r tinyg && useradd -r -g tinyg tinyu

# Correct permissions
RUN chmod 0550 /usr/local/bin/trump_search.sh \
 && chgrp tinyg /usr/local/bin/trump_search.sh \
 && chmod 0550 /entrypoint.sh \
 && chgrp tinyg /entrypoint.sh

LABEL org.opencontainers.image.description="Container to search for trumped movies, delete them, and search for new copy"

# Set environment variables
ENV PATH="/venv/bin:${PATH}"
ENV SLEEP=15

# Set user to non-root
USER tinyu

# Test rtcontrol installation
RUN /venv/bin/rtcontrol --help >/dev/null

# Start
CMD ["/entrypoint.sh"]