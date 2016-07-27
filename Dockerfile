FROM haproxy:1.6-alpine
MAINTAINER Kennedy Brown | thoughtarray

ENV CONSUL_ADDR consul
ENV CONSUL_PORT 8500
ENV CONSUL_TEMPLATE_CONFIG /usr/local/etc/consul-template/consul-template.conf

# Overlay S6
ADD https://github.com/just-containers/s6-overlay/releases/download/v1.18.1.3/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C / && rm /tmp/s6-overlay-amd64.tar.gz

# Install Consul Template
ADD https://releases.hashicorp.com/consul-template/0.15.0/consul-template_0.15.0_linux_amd64.zip /tmp/consul-template.zip
RUN mkdir -p /usr/local/etc/consul-template/ \
  && unzip /tmp/consul-template.zip -d /usr/local/bin/ \
  && rm /tmp/consul-template.zip

# Custom overlay
COPY docker_base /

ENTRYPOINT ["/init"]

# TODO: Might need to overwrite the parent image's RUN directive
