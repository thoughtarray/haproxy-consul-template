FROM alpine:3.4
MAINTAINER Kennedy Brown | thoughtarray

# Install ContainerPilot
ENV CONTAINERPILOT=file:///usr/local/etc/containerpilot/containerpilot.json \
  CONTAINERPILOT_HASH=198d96c8d7bfafb1ab6df96653c29701510b833c
ADD https://github.com/joyent/containerpilot/releases/download/2.4.1/containerpilot-2.4.1.tar.gz /tmp/cp.tar.gz
RUN echo "$CONTAINERPILOT_HASH  /tmp/cp.tar.gz" | sha1sum -c \
  && tar xzf /tmp/cp.tar.gz -C /usr/local/bin/

# Overlay S6
# ADD https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.3/s6-overlay-amd64.tar.gz /tmp/
# RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm /tmp/s6-overlay-amd64.tar.gz

# Install HAProxy
RUN apk --update-cache --no-cache add \
  haproxy=1.6.6-r1 \
  haproxy-systemd-wrapper=1.6.6-r1

# Install Consul Template
ENV CONSUL_ADDR=localhost \
  CONSUL_PORT=8500 \
  CONSUL_TEMPLATE_CONFIG=/usr/local/etc/consul-template/consul-template.conf \
  CONSUL_HASH=b7561158d2074c3c68ff62ae6fc1eafe8db250894043382fb31f0c78150c513a
ADD https://releases.hashicorp.com/consul-template/0.15.0/consul-template_0.15.0_linux_amd64.zip /tmp/ct.zip
RUN echo "$CONSUL_HASH  /tmp/ct.zip" | sha256sum -c \
  && unzip /tmp/ct.zip -d /usr/local/bin/

# Custom overlay
COPY docker_base /

ENTRYPOINT ["containerpilot"]
CMD $(which haproxy-systemd-wrapper) -p /run/haproxy.pid -f /etc/haproxy/haproxy.cfg
