FROM alpine:3.16.2 as builder

RUN apk update && \
    apk upgrade && \
    apk add util-linux

FROM alpine:3.16.2

RUN  apk update && apk upgrade && \
     apk add apache2 && \
     apk add apache2-proxy && \
     apk add apache2-ssl && \
     apk add curl && \
     rm -rf /var/cache/apk/*

COPY --from=builder /usr/bin/script /usr/bin/

EXPOSE 80

CMD  [ "/usr/sbin/httpd", "-D", "FOREGROUND"]
