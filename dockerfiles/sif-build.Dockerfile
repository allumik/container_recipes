FROM alpine:3.17
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

## Locale settings
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
## ensure installation is stripped
ENV _R_SHLIB_STRIP_=true
## Alpine does not detect timezone
ENV TZ=UTC

RUN \
  echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk add libattr apptainer@testing