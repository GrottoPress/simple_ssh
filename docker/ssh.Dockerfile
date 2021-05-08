FROM panubo/sshd:1.3.0

RUN apk add --no-cache sudo

COPY ./spec/support/ssh/id_rsa.pub /root/.ssh/authorized_keys
