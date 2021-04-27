FROM ubuntu:16.04 as builder

WORKDIR /root

# install blockstream's esplora version of electrs

RUN apt-get update && \
    apt-get install git build-essential libtool autotools-dev automake pkg-config \
    bsdmainutils python3 -y && \
    apt-get install -y wget software-properties-common apt-transport-https && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-add-repository "deb https://apt.llvm.org/xenial/ llvm-toolchain-xenial-10 main" && \
    apt-get update && \
    apt-get install -y libllvm10 clang-10 libclang-common-10-dev curl cargo

RUN git clone https://github.com/blockstream/electrs
WORKDIR electrs
RUN cargo build --release --bin electrs

FROM bitcoindevkit/bitcoind:0.2.0

COPY --from=builder /root/electrs/target/release/electrs /root

RUN chmod a+rx /root
RUN chmod a+rx /root/electrs

EXPOSE 18443 18444 60401 3002

ADD entrypoint.sh /root/entrypoint.sh
RUN chmod a+x /root/entrypoint.sh

CMD ["/root/entrypoint.sh"]