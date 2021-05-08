FROM crystallang/crystal:1.0.0-alpine

RUN apk add --no-cache openssh-client

COPY ./spec/support/ssh/* /root/.ssh/

RUN chmod 0600 /root/.ssh/id_rsa
