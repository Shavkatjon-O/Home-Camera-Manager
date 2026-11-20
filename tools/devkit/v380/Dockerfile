FROM alexxit/go2rtc:1.9.14

ARG REVISION=unknown
LABEL org.opencontainers.image.title="smart-surveillance-dev-v380-camera" \
      org.opencontainers.image.description="Simulated V380 camera of the development kit" \
      org.opencontainers.image.source="https://github.com/Shavkatjon-O/Smart-Surveillance-System" \
      org.opencontainers.image.revision="${REVISION}"

COPY aes.py media.py simulator.py /usr/local/lib/v380/
COPY entrypoint.sh /usr/local/bin/v380-entrypoint.sh
RUN chmod 0755 /usr/local/bin/v380-entrypoint.sh

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

USER 10001:10001

EXPOSE 8800 10008/udp

HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=5 \
    CMD ["python3", "-c", "import socket; socket.create_connection(('127.0.0.1', 8800), 2).close()"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/v380-entrypoint.sh"]
