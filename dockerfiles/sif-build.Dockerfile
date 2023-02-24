FROM alpine:3.17
LABEL maintainer="Alvin Meltsov <alvinmeltsov@gmail.com>"

## Locale settings
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
## Alpine does not detect timezone
ENV TZ=UTC

# install the apptainer package in the testing
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
  && apk add --no-cache ca-certificates libattr apptainer-suid@testing squashfs-tools \
  && rm -rf /tmp/* /var/cache/apk/*

# setup cloud.sycloud.io as a remote library for compatibility with
# old singularity definition files
# per: https://apptainer.org/docs/user/latest/endpoint.html#restoring-pre-apptainer-library-behavior
RUN apptainer remote add --no-login SylabsCloud cloud.sycloud.io \
  && apptainer remote use SylabsCloud

## TODO: user namespace support for Docker 
## generate userspace for user $NEWUSER
# ENV NEWUSER='appuser'
# RUN apk add --no-cache sudo shadow-uidmap \
#   && addgroup -S appgroup \
#   && adduser -S $NEWUSER -G appgroup wheel \
#   && echo "$NEWUSER ALL=(ALL) ALL" > /etc/sudoers.d/$NEWUSER \
#   && chmod 0440 /etc/sudoers.d/$NEWUSER \
#   && echo ${NEWUSER}:100000:65536 >/etc/subuid \
#   && echo ${NEWUSER}:100000:65536 >/etc/subgid

## setup workdir to mount onto
RUN mkdir /app
WORKDIR /app
ENTRYPOINT ["/usr/bin/singularity"]