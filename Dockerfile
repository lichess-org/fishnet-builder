FROM alpine:edge
WORKDIR /fishnet
COPY sgerrand.rsa.pub /etc/apk/keys/sgerrand.rsa.pub
COPY glibc-2.35-r0.apk /opt/glibc-2.35-r0.apk
COPY glibc-bin-2.35-r0.apk /opt/glibc-bin-2.35-r0.apk
COPY sde-external-9.0.0-2021-11-07-lin /opt/sde-external-9.0.0-2021-11-07-lin
RUN apk --no-cache add /opt/glibc-2.35-r0.apk /opt/glibc-bin-2.35-r0.apk git make curl g++ rust cargo
RUN cargo install cargo-auditable
RUN ln -s /opt/sde-external-9.0.0-2021-11-07-lin/misc/ /usr/glibc-compat/lib/; \
    ln -s /opt/sde-external-9.0.0-2021-11-07-lin/intel64/ /usr/glibc-compat/lib/
ENV LDFLAGS=-static \
    SDE_PATH="/usr/glibc-compat/lib/ld-linux-x86-64.so.2 /opt/sde-external-9.0.0-2021-11-07-lin/sde64"
#RUN apk --no-cache --upgrade add git make curl g++ rust cargo
#RUN mkdir /debian && debootstrap --variant=minbase bullseye /debian http://httpredir.debian.org/debian/
#COPY sde64.sh /usr/local/bin/sde64

RUN git clone https://github.com/official-stockfish/Stockfish.git
