ARG SWAGGERUI_TAG=v4.2.1
FROM swaggerapi/swagger-ui:${SWAGGERUI_TAG}

ARG AUTH_USER=gimic
ARG AUTH_PASSWORD=Gimic2022

RUN set -x \
    && apk update --no-cache \
    && apk add --no-cache openssl \
    && echo "${AUTH_USER}:$(openssl passwd -crypt ${AUTH_PASSWORD})" | tee /etc/nginx/.htpasswd \
    && sed -i 's/^\s*server\s*{\s*$/server { auth_basic "authentication required"; auth_basic_user_file \/etc\/nginx\/.htpasswd;/' /etc/nginx/nginx.conf \
    && apk del openssl

COPY --chown=nginx:nginx . /usr/share/nginx/html/
ENV SWAGGER_JSON_URL main.yaml

RUN chmod +x /docker-entrypoint.sh
