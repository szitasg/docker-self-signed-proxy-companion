FROM alpine:3.21.2

RUN apk update \
 && apk upgrade --no-cache \
 && apk add --no-cache \
        bash==5.2.37-r0 \
        curl==8.12.0-r0 \
        jq==1.7.1-r0 \
        openssl==3.3.2-r5

ARG OS=alpine-linux
ARG ARCH=amd64
ARG DOCKER_GEN_VERSION=0.14.5

RUN curl -L https://github.com/jwilder/docker-gen/releases/download/${DOCKER_GEN_VERSION}/docker-gen-${OS}-${ARCH}-${DOCKER_GEN_VERSION}.tar.gz -o docker-gen.tar.gz \
 && tar xvzf docker-gen.tar.gz -C /usr/local/bin \
 && rm docker-gen.tar.gz

WORKDIR /app
COPY . /app

ENV DOCKER_HOST=unix:///var/run/docker.sock
ENV NGINX_PROXY_CONTAINER=nginx
ENV EXPIRATION=3650

ENTRYPOINT [ "/bin/bash", "/app/entrypoint.sh" ]
CMD [ "/bin/bash", "/app/start.sh" ]
