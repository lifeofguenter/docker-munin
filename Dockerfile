FROM alpine:3.17

ENV MUNIN_VERSION="2.999.16"

EXPOSE 4948

ENTRYPOINT ["munin-httpd"]
CMD ["--listen", "0.0.0.0:4948"]

RUN set -ex && \
    apk add --no-cache \
      bash \
      font-dejavu \
      grep \
      musl \
      perl \
      perl-clone \
      perl-dbd-sqlite \
      perl-dbi \
      perl-http-headers-fast \
      perl-http-server-simple \
      perl-io-socket-inet6 \
      perl-json \
      perl-log-dispatch \
      perl-net-ssleay \
      perl-parallel-forkmanager \
      perl-params-validate \
      perl-rrd \
      perl-socket6 \
      perl-uri \
      perl-xml-parser \
      sed && \
    apk add --no-cache --virtual .build-deps \
      gcc \
      make \
      musl-dev \
      perl-dev \
      perl-app-cpanminus \
      perl-module-build && \
    cd /tmp && \
    wget "https://github.com/munin-monitoring/munin/archive/refs/tags/${MUNIN_VERSION}.tar.gz" && \
    tar xf "${MUNIN_VERSION}.tar.gz" && \
    cd munin-* && \
    make INSTALLDIRS=vendor && \
    make install INSTALLDIRS=vendor && \
    cd .. && \
    rm -rf munin-* &&  \
    cpanm \
      "HTTP::Server::Simple::CGI::PreFork" \
      "HTML::Template::Pro" \
      "XML::Dumper" && \
    apk del .build-deps && \
    addgroup -S munin && \
    adduser -h /var/lib/munin -S -s /sbin/nologin -G munin munin && \
    mkdir /var/run/munin && \
    chown munin:munin /var/run/munin

USER munin

WORKDIR /var/lib/munin
VOLUME /var/lib/munin
