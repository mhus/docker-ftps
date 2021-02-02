FROM alpine:3.13.1

# Labels
LABEL Description "Our goal is to create a simple, consistent, customizable and convenient image using official image" \
	  maintainer "https://github.com/chonjay21"

# Environment variables
ENV FTPS_SOURCE_DIR=/sources/ftps

# install apps... (shadow for usermod/groupmode)
RUN apk update && apk upgrade; \
	apk add --no-cache \
	shadow \
	bash \
	tzdata \
	vsftpd \
	curl \
	openssl \
	python3

# creating self signed certificate
RUN mkdir -p /usr/certs; \
	openssl req -x509 -nodes -days 36500 -newkey rsa:2048 -subj "/C=US/ST=Docker/L=Docker/O=httpd/CN=*" -keyout /usr/certs/cert.key -out /usr/certs/cert.crt; \
	chmod 644 /usr/certs/cert.key; \
	chmod 644 /usr/certs/cert.crt; \
	apk del openssl

ADD sources/ $FTPS_SOURCE_DIR/

# set permission
RUN chmod 770 $FTPS_SOURCE_DIR/*

ENTRYPOINT $FTPS_SOURCE_DIR/entrypoint.sh
