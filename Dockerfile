FROM alpine:3.8

ENV LANG=C.UTF-8 \
    LC_ALL=C \
    PURE_FTPD_VERSION=1.0.47

RUN apk add --update --virtual .build-deps \
        build-base \
        curl \
        openssl-dev \
    \
    && curl -L -o /tmp/pure-ftpd.tar.gz https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${PURE_FTPD_VERSION}.tar.gz \
    && tar xfz /tmp/pure-ftpd.tar.gz \
    && cd pure-ftpd-${PURE_FTPD_VERSION} \
    \
    && ./configure --with-everything --with-tls \
    && make install \
    \
    && runDeps="$( \
            scanelf --needed --nobanner --recursive /usr/local \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
        )" \
    && apk add ${runDeps} \
    \
    && apk del .build-deps \
    \
    && rm -rf /var/cache/apk/* \
    && rm -rf /tmp/* \
    \
    && mkdir -p /home/ftpuser \
    && addgroup ftpgroup \
    && adduser -G ftpgroup -h /home/ftpuser -s /bin/false -D ftpuser \
    && chmod g+w /home/ftpuser \
    && chown ftpuser.ftpgroup /home/ftpuser

ENV PUREFTPD_PUBLICHOST=localhost

COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 21 30000-30009
