FROM alpine:edge
WORKDIR /fishnet
ENV LDFLAGS=-static SDE_PATH=/usr/local/bin/sde64
RUN apk --no-cache add git make curl g++ debootstrap rust cargo
RUN mkdir /debian && debootstrap --variant=minbase bullseye /debian http://httpredir.debian.org/debian/
COPY sde-external-9.0.0-2021-11-07-lin /debian/opt/sde-external-9.0.0-2021-11-07-lin
COPY sde64.sh /usr/local/bin/sde64

RUN git clone https://github.com/official-stockfish/Stockfish.git
