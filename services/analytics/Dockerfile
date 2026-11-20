FROM nvcr.io/nvidia/deepstream:9.1-samples-multiarch AS parsers

RUN apt-get update \
    && apt-get install -y --no-install-recommends cuda-cudart-dev-13-2 cuda-crt-13-2 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY parsers ./
RUN make


FROM nvcr.io/nvidia/deepstream:9.1-samples-multiarch AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_ROOT_USER_ACTION=ignore \
    HOME=/tmp \
    GST_DEBUG=1

RUN /opt/nvidia/deepstream/deepstream/user_additional_install.sh \
    && apt-get install -y --no-install-recommends libpython3.12t64 python3-yaml python3-numpy python3-pil tzdata \
    && rm -rf /var/lib/apt/lists/* /root/.cache/gstreamer-1.0

COPY --from=parsers /build/libnvds_rfdetr_parser.so /opt/analytics/lib/

WORKDIR /opt/analytics
COPY pyproject.toml ./
COPY app ./app
COPY scripts ./scripts
RUN sh scripts/tracker-config.sh \
    && pip3 install --no-deps . && rm -rf build *.egg-info

RUN groupadd --system --gid 10001 analytics \
    && useradd --system --uid 10001 --gid analytics --no-create-home --shell /usr/sbin/nologin analytics \
    && mkdir -p /engines /clips /buffer \
    && chown analytics:analytics /engines /clips /buffer

USER analytics

EXPOSE 8080

CMD ["python3", "-m", "app"]


FROM runtime AS test

USER root
RUN pip3 install "pytest>=8.4" "ruff>=0.12"
COPY tests ./tests
USER analytics
CMD ["sh", "-c", "ruff check --no-cache . && ruff format --no-cache --check . && pytest -q -p no:cacheprovider"]
