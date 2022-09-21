# syntax=docker/dockerfile:1

#############################################################################
# Builder container                                                         #
#############################################################################
FROM --platform="$BUILDPLATFORM" golang:1-buster AS builder

ARG TARGETARCH

ARG OATHKEEPER_VERSION=v0.40.0
ARG OATHKEEPER_ARCHIVE_URL="https://github.com/ory/oathkeeper/archive/refs/tags/$OATHKEEPER_VERSION.tar.gz"
ARG OATHKEEPER_ARCHIVE_SHA256=60c7e1382049ecbcb96aac155b692d0dd65ae7f31e52de3323e8b26ebcc98261

WORKDIR /workspace

ADD --link "$OATHKEEPER_ARCHIVE_URL" archive.tar.gz
RUN echo "$OATHKEEPER_ARCHIVE_SHA256  archive.tar.gz" | sha256sum -c
RUN tar xzf archive.tar.gz --strip-components=1

ENV CGO_ENABLED=0
ENV GOARCH="$TARGETARCH"
ENV GOOS=linux

RUN --mount=type=cache,target=/go/pkg/mod,sharing=locked \
    --mount=type=cache,target=/root/.cache/go-build,sharing=private \
    go build

#############################################################################
# Release container                                                         #
#############################################################################
FROM registry.access.redhat.com/ubi8-minimal AS release

COPY --from=builder \
    /workspace/oathkeeper \
    /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/oathkeeper"]
CMD ["serve"]
