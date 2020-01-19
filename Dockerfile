FROM alpine

ENV BITCOIN_REPO=https://github.com/jimpo/bitcoin.git
ENV BITCOIN_BRANCH=bip157-net

WORKDIR /opt/bitcoin

RUN apk update && apk add git \
                          make \
                          file \
                          autoconf \
                          automake \
                          build-base \
                          libtool \
                          db-c++ \
                          db-dev \
                          boost-system \
                          boost-program_options \
                          boost-filesystem \
                          boost-dev \
                          libressl-dev \
                          libevent-dev

RUN git clone $BITCOIN_REPO --branch $BITCOIN_BRANCH --single-branch

RUN (cd bitcoin  && ./autogen.sh && \
                      ./configure --disable-tests \
                      --disable-bench --disable-static  \
                      --without-gui --disable-zmq \
                      --with-incompatible-bdb \
                      CFLAGS='-w' CXXFLAGS='-w' && \
                      make -j 4 && \
                      strip src/bitcoind && \
                      strip src/bitcoin-cli && \
                      strip src/bitcoin-tx && \
                      make install )