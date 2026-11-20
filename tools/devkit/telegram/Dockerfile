FROM python:3.13.11-slim-bookworm

ARG REVISION=unknown
LABEL org.opencontainers.image.title="smart-surveillance-dev-telegram" \
      org.opencontainers.image.description="Fake Telegram Bot API of the development kit" \
      org.opencontainers.image.source="https://github.com/Shavkatjon-O/Smart-Surveillance-System" \
      org.opencontainers.image.revision="${REVISION}"

RUN groupadd --system --gid 10001 fake && useradd --system --uid 10001 --gid fake --no-create-home fake

COPY fake_telegram.py /app/fake_telegram.py

USER 10001
EXPOSE 8081
HEALTHCHECK --interval=10s --timeout=3s --retries=5 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8081/fake/health', timeout=2)"]
CMD ["python", "/app/fake_telegram.py"]
