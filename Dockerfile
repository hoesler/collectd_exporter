FROM bitnami/minideb:stretch as builder
RUN install_packages \
	build-essential \
	ca-certificates \
	curl \
	git \
	wget

ARG GO_VERSION="1.12.5"
RUN wget -nv -O - https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz | tar -C /usr/local -xz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN mkdir /build
COPY . /build/
RUN cd /build &&  make

FROM bitnami/minideb:stretch

RUN install_packages \
	dumb-init \
	gosu

RUN useradd -U collectd-exporter
COPY --from=builder /build/prometheus-collectd-exporter /usr/local/bin
COPY docker-entrypoint.sh /usr/local/sbin

EXPOSE 9103
ENTRYPOINT ["/usr/bin/dumb-init", "--", "docker-entrypoint.sh"]
CMD ["prometheus-collectd-exporter"]
