FROM alexxit/go2rtc:1.9.14

ARG REVISION=unknown
LABEL org.opencontainers.image.title="smart-surveillance-dev-camera" \
      org.opencontainers.image.description="Simulated IP camera of the development kit" \
      org.opencontainers.image.source="https://github.com/Shavkatjon-O/Smart-Surveillance-System" \
      org.opencontainers.image.revision="${REVISION}"

COPY responder.py /usr/local/lib/camera/responder.py
COPY entrypoint.sh /usr/local/bin/camera-entrypoint.sh
RUN chmod +x /usr/local/bin/camera-entrypoint.sh

EXPOSE 554 80 3702/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/camera-entrypoint.sh"]
