FROM alexxit/go2rtc:1.9.14

COPY responder.py /usr/local/lib/camera/responder.py
COPY entrypoint.sh /usr/local/bin/camera-entrypoint.sh
RUN chmod +x /usr/local/bin/camera-entrypoint.sh

EXPOSE 554 80 3702/udp

ENTRYPOINT ["/sbin/tini", "--", "/usr/local/bin/camera-entrypoint.sh"]
