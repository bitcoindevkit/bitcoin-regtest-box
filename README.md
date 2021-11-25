# THIS PROJECT IS NO LONGER ACTIVELY MAINTAINED

### Purpose

Originally the [`bdk`] project used the images created by this repo for github actions integration 
testing for its `electrum` and `esplora` blockchain client modules. But the new solution for [`bdk`] 
blockchain testing is to use the [`bitcoind`] and [`electrsd`] rust crates which are easier to 
maintain, allow parallel testing, and don't require docker. For local [`bdk`] and [`bdk-cli`] testing 
_without_ using this repo see below instructions.

### Local BDK Testing

To run the blockchain integration tests for [`bdk`] the required daemons are now automatically
installed, started, and stopped by `cargo test`, all you need to do is specify the correct features.

**NOTE**: On a MacOS system you will get pop-up warnings that you must click "OK" for.
    
For example, from your clone of [`bdk`]: 
```shell
cargo test --no-default-features --features test-electrum electrum::bdk_blockchain_tests
cargo test --no-default-features --features test-rpc rpc::bdk_blockchain_tests
cargo test --no-default-features --features test-esplora,use-esplora-reqwest esplora::bdk_blockchain_tests
cargo test --no-default-features --features test-esplora,use-esplora-ureq esplora::bdk_blockchain_tests
```

### Local BDK-CLI Testing

To manually test [`bdk-cli`] in regtest mode with locally installed `bitcoind` and `electrs` daemons 
you will need to install them yourself.

1. Manually download and install the [bitcoincore.org `bitcoind`] daemon and `bitcoin-cli` binaries
2. Build from source and install the [romanz `electrs`] daemon
3. Install [`bdk-cli`] from your clone with `cargo install --features electrum --path .` or from 
   crates.io `cargo install --features electrum bdk-cli`

With all above binaries in your local local `$PATH` you can run them in `regtest` mode and use them 
for manual `bdk-cli` testing like this:

```shell
mkdir -p /tmp/regtest1/bitcoind /tmp/regtest1/electrs
bitcoind -datadir=/tmp/regtest1/bitcoind -regtest -server -fallbackfee=0.0002 -rpcallowip=0.0.0.0/0 -rpcbind=0.0.0.0 -blockfilterindex=1 -peerblockfilters=1 -daemon
electrs --daemon-dir /tmp/regtest1/bitcoind --db-dir /tmp/regtest1/electrs --network regtest
```

In a new shell: 
```shell
# 1. create bitcoind test wallet and generate regtest test coins
bitcoin-cli -regtest -datadir=/tmp/regtest1/bitcoind createwallet bdk-test
GEN_ADDRESS=$(bitcoin-cli -regtest -datadir=/tmp/regtest1/bitcoind getnewaddress)
bitcoin-cli -regtest -datadir=/tmp/regtest1/bitcoind generatetoaddress 101 $GEN_ADDRESS

# 2. sync wallet via the electrum APIs
DESCRIPTOR="wpkh(tpubEBr4i6yk5nf5DAaJpsi9N2pPYBeJ7fZ5Z9rmN4977iYLCGco1VyjB9tvvuvYtfZzjD5A8igzgw3HeWeeKFmanHYqksqZXYXGsw5zjnj7KM9/*)"
bdk-cli -n regtest wallet --server tcp://127.0.0.1:60401 --descriptor $DESCRIPTOR sync     
 
# 3. receive a deposit
DEPOSIT_ADDRESS=$(bdk-cli -n regtest wallet --server tcp://127.0.0.1:60401 --descriptor $DESCRIPTOR get_new_address | jq '.address' | tr -d '"')
bitcoin-cli -regtest -datadir=/tmp/regtest1/bitcoind sendtoaddress $DEPOSIT_ADDRESS 10
bitcoin-cli -regtest -datadir=/tmp/regtest1/bitcoind generatetoaddress 1 $GEN_ADDRESS
bdk-cli -n regtest wallet --server tcp://127.0.0.1:60401 --descriptor $DESCRIPTOR sync 
bdk-cli -n regtest wallet --server tcp://127.0.0.1:60401 --descriptor $DESCRIPTOR get_balance
 
# 4. kill the electrs and bitcoind containers when you're done
pkill electrs bitcoind

# 5. remove the /tmp data
rm -rf /tmp/regtest1
rm -rf ~/.bdk-bitcoin
```

[`bdk`]: https://github.com/bitcoindevkit/bdk
[`bdk-cli`]: https://github.com/bitcoindevkit/bdk-cli
[`bitcoind`]: https://github.com/rcasatta/bitcoind
[`electrsd`]: https://github.com/rcasatta/electrsd
[bitcoincore.org `bitcoind`]: https://bitcoincore.org/en/download/
[romanz `electrs`]: https://github.com/romanz/electrs

## OLD DOCS BELOW

### Github actions

Below are examples of how to use the images created by this project in github actions jobs:

#### electrum test job 
    
   ```
    test-electrum:
        name: Test Electrum
        runs-on: ubuntu-16.04
        container: bitcoindevkit/electrs:<version>
        env:
          BDK_RPC_AUTH: COOKIEFILE
          BDK_RPC_COOKIEFILE: /root/.bitcoin/regtest/.cookie
          BDK_RPC_URL: 127.0.0.1:18443
          BDK_RPC_WALLET: bdk-test
          BDK_ELECTRUM_URL: tcp://127.0.0.1:60401
        ...
   ```
   
#### esplora test job
    
   ```
    test-esplora:
        name: Test Esplora
        runs-on: ubuntu-16.04
        container: bitcoindevkit/esplora:<version>
        env:
          BDK_RPC_AUTH: COOKIEFILE
          BDK_RPC_COOKIEFILE: /root/.bitcoin/regtest/.cookie
          BDK_RPC_URL: 127.0.0.1:18443
          BDK_RPC_WALLET: bdk-test
          BDK_ELECTRUM_URL: tcp://127.0.0.1:60401
          BDK_ESPLORA_URL: http://127.0.0.1:3002
        ...
   ```
    
### Local `bdk` testing

Below is an example of how to run `bdk` electrum blockchain tests locally using the electrs docker image:

   ```shell
    # start the electrs docker container
    docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --detach --rm --name electrs bitcoindevkit/electrs
   
    # confirm electrs is running
    docker logs electrs
   
    # get a copy of the bitcoind .cookie file
    # this needs to be done each time you run the container because the cookie file will change
    docker cp electrs:/root/.bitcoin/regtest/.cookie /tmp/regtest.cookie
   
    # in new shell from the `bdk` project repo directory run blockchains integration tests
    export BDK_RPC_AUTH=COOKIEFILE
    export BDK_RPC_COOKIEFILE=/tmp/regtest.cookie
    export BDK_RPC_URL=127.0.0.1:18443
    export BDK_RPC_WALLET=bdk-test
    export BDK_ELECTRUM_URL=tcp://127.0.0.1:60401
    
    cargo test --features electrum,test-blockchains --no-default-features electrum::bdk_blockchain_tests
    
    # kill the electrs container when you're done
    docker kill electrs
   ```
   
Below is an example of how to run `bdk` esplora blockchain tests locally using the esplora docker image:

  ```shell
   # start the esplora docker container
   docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp -p 127.0.0.1:3002:3002/tcp --detach --rm --name esplora bitcoindevkit/esplora
  
   # confirm esplora is running
   docker logs esplora
       
   # get a copy of the bitcoind .cookie file
   # this needs to be done each time you run the container because the cookie file will change
   docker cp esplora:/root/.bitcoin/regtest/.cookie /tmp/regtest.cookie
  
   # in new shell from the `bdk` project repo directory run blockchains integration tests
   export BDK_RPC_AUTH=COOKIEFILE
   export BDK_RPC_COOKIEFILE=/tmp/regtest.cookie
   export BDK_RPC_URL=127.0.0.1:18443
   export BDK_RPC_WALLET=bdk-test
   export BDK_ELECTRUM_URL=tcp://127.0.0.1:60401
   export BDK_ESPLORA_URL=http://127.0.0.1:3002
   
   cargo test --features esplora,test-blockchains --no-default-features esplora::bdk_blockchain_tests
   
   # kill the esplora container when you're done
   docker kill esplora
  ```
   
### Local `bdk-cli` testing

Below is an example of how to test `bdk-cli` with electrum or esplora server APIs locally using the 
esplora docker image:

   ```shell
    # start esplora docker container
    docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp -p 127.0.0.1:3002:3002/tcp --detach --rm --name esplora bitcoindevkit/esplora
    
    # in a new shell sync wallet via the electrum APIs
    bdk-cli -n regtest wallet --server tcp://127.0.0.1:60401 --descriptor "wpkh(tpubEBr4i6yk5nf5DAaJpsi9N2pPYBeJ7fZ5Z9rmN4977iYLCGco1VyjB9tvvuvYtfZzjD5A8igzgw3HeWeeKFmanHYqksqZXYXGsw5zjnj7KM9/*)" sync     
    
    # or sync wallet via the esplora APIs
    bdk-cli -n regtest wallet --esplora http://127.0.0.1:3002 --descriptor "wpkh(tpubEBr4i6yk5nf5DAaJpsi9N2pPYBeJ7fZ5Z9rmN4977iYLCGco1VyjB9tvvuvYtfZzjD5A8igzgw3HeWeeKFmanHYqksqZXYXGsw5zjnj7KM9/*)" sync
    
    # kill the esplora container when you're done
    docker kill esplora   
   ```
  
### Create aliases with the electrs container for local regtest electrum testing

   ```shell
   alias elstart='docker run --detach --rm -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs'
   alias elstop='docker kill electrs'
   alias ellogs='docker container logs electrs'
   alias elcli='docker exec -it electrs /root/bitcoin-cli -regtest -datadir=/root/.bitcoin $@'
   ```
   
### Use aliases with the esplora container for local regtest electrum and esplora testing

   ```shell
   alias esstart='docker run --detach --rm -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp -p 127.0.0.1:3002:3002/tcp --name esplora bitcoindevkit/esplora'
   alias esstop='docker kill esplora'
   alias eslogs='docker container logs esplora'
   alias escli='docker exec -it esplora /root/bitcoin-cli -regtest -datadir=/root/.bitcoin $@'
   ```
  
### Use aliases to start an electrum container, view logs, run bitcoind cli commands, and stop the container

   ```shell
   elstart  
   ellogs  
   elcli help    
   elcli getwalletinfo    
   elcli getnewaddress  
   elstop  
   ```

### Build local regtest bitcoind, electrs and esplora docker images and push to docker hub

These steps are only needed if you are a maintainer creating new versions of the published docker 
images for this project.

1. Login to docker hub

   `docker login`

1. Build and push new version of images, where <version> is new git tag for this repo

   ```shell
   docker build -t bitcoindevkit/bitcoind:<version> bitcoind  
   docker build -t bitcoindevkit/electrs:<version> electrs
   docker build -t bitcoindevkit/esplora:<version> esplora

   docker push bitcoindevkit/bitcoind:<version>
   docker push bitcoindevkit/electrs:<version>
   docker push bitcoindevkit/esplora:<version>
   ```
   
1. Build and push `latest` image versions as needed

   ```shell
   docker build -t bitcoindevkit/bitcoind:latest bitcoind  
   docker build -t bitcoindevkit/electrs:latest electrs
   docker build -t bitcoindevkit/esplora:latest esplora
   
   docker push bitcoindevkit/bitcoind:latest
   docker push bitcoindevkit/electrs:latest
   docker push bitcoindevkit/esplora:latest
   ```
