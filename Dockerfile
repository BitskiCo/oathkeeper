# syntax=docker/dockerfile:1

#############################################################################
# Builder container                                                         #
#############################################################################
FROM --platform="$BUILDPLATFORM" \
    registry.access.redhat.com/ubi8/go-toolset AS builder

ARG TARGETARCH

ARG OATHKEEPER_VERSION=v0.39.0
ARG OATHKEEPER_ARCHIVE_URL="https://github.com/ory/oathkeeper/archive/refs/tags/$OATHKEEPER_VERSION.tar.gz"
ARG OATHKEEPER_ARCHIVE_SHA256=be9080e7fe1a0c57fa61ca724d1fad7deeec45fe10981d62f3a46220ea6786b0

# Workaround build errors
USER root
RUN ln -s /opt /usr/lib/golang/src/opt

ADD --link "$OATHKEEPER_ARCHIVE_URL" archive.tar.gz
RUN echo "$OATHKEEPER_ARCHIVE_SHA256  archive.tar.gz" | sha256sum -c
RUN tar xzf archive.tar.gz --strip-components=1

ENV CGO_ENABLED=0
ENV GOARCH="$TARGETARCH"
ENV GOOS=linux
ENV PATH="/opt/app-root/src/go/bin:$PATH"

RUN --mount=type=cache,target=/opt/app-root/src/go \
    --mount=type=cache,target=/opt/app-root/src/.cache \
    go install github.com/gobuffalo/packr/v2/packr2@v2.8.0 && \
    packr2 build

#############################################################################
# Release container                                                         #
#############################################################################
FROM registry.access.redhat.com/ubi8-minimal AS release

COPY --from=builder \
    /opt/app-root/src/oathkeeper \
    /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/oathkeeper"]
CMD ["serve"]
