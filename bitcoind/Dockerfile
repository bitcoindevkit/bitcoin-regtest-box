FROM ubuntu:16.04 as builder

WORKDIR /root

# install bitcoind

ENV BITCOIN_REPO=https://github.com/bitcoin/bitcoin.git
ENV BITCOIN_BRANCH=master
ENV BITCOIN_TAG=v0.20.1

RUN apt-get update && \
    apt-get install git build-essential libtool autotools-dev automake pkg-config \
    bsdmainutils python3 -y && \
    apt-get install libevent-dev libboost-system-dev libboost-filesystem-dev libboost-test-dev \
    libboost-thread-dev libdb-dev libdb++-dev -y && \
    git clone $BITCOIN_REPO --branch $BITCOIN_BRANCH --single-branch

RUN (cd bitcoin && git fetch --all --tags --prune && git checkout tags/$BITCOIN_TAG && \
      ./autogen.sh && \
      ./configure --disable-tests \
      --disable-bench --disable-static  \
      --without-gui --disable-zmq \
      --with-incompatible-bdb \
      CFLAGS='-w' CXXFLAGS='-w' && \
      make -j 4 && \
      strip src/bitcoind && \
      strip src/bitcoin-cli && \
      strip src/bitcoin-tx )

FROM ubuntu:16.04

RUN apt-get update && apt-get install -y libevent-dev libboost-system-dev libboost-filesystem-dev \
    libboost-thread-dev libdb-dev libdb++-dev curl build-essential

COPY --from=builder /root/bitcoin/src/bitcoind /root
COPY --from=builder /root/bitcoin/src/bitcoin-cli /root
COPY --from=builder /root/bitcoin/src/bitcoin-tx /root

EXPOSE 18444 18443

ADD entrypoint.sh /root/entrypoint.sh
RUN chmod a+x /root/entrypoint.sh

CMD ["/root/entrypoint.sh"]