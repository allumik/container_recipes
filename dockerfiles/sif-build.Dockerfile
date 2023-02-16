FROM alpine:3.17
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

## Locale settings
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
## ensure installation is stripped
ENV _R_SHLIB_STRIP_=true
## Alpine does not detect timezone
ENV TZ=UTC

# install the apptainer package in the edge
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
  apk add libattr apptainer@testing

ENV NEWUSER='appuser'

# add user with root privs
RUN addgroup -S appgroup \
  && adduser -S $NEWUSER -G appgroup \
  && echo "$NEWUSER ALL=(ALL) ALL" > /etc/sudoers.d/$NEWUSER \
  && chmod 0440 /etc/sudoers.d/$NEWUSER \
  && echo ${NEWUSER}:100000:65536 >/etc/subuid \
  && echo ${NEWUSER}:100000:65536 >/etc/subgid

# setup workdir
RUN mkdir /app
WORKDIR /app