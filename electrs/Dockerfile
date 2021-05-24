FROM ubuntu:16.04 as builder

WORKDIR /root

# install electrs

RUN apt-get update && \
    apt-get install git build-essential libtool autotools-dev automake pkg-config \
    bsdmainutils python3 -y && \
    apt-get install -y wget software-properties-common apt-transport-https && \
    wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    apt-add-repository "deb https://apt.llvm.org/xenial/ llvm-toolchain-xenial-10 main" && \
    apt-get update && \
    apt-get install -y libllvm10 clang-10 libclang-common-10-dev curl cargo

RUN cargo install --git https://github.com/romanz/electrs --tag v0.8.10 --bin electrs

FROM bitcoindevkit/bitcoind:0.3.0

COPY --from=builder /root/.cargo/bin/electrs /root

RUN chmod a+rx /root
RUN chmod a+rx /root/electrs

EXPOSE 18443 18444 60401

ADD config.toml /etc/electrs/config.toml
ADD entrypoint.sh /root/entrypoint.sh
RUN chmod a+x /root/entrypoint.sh

CMD ["/root/entrypoint.sh"]