### Purpose

This purpose of this project is to create docker images that can be used to run `bdk` regtest 
network tests locally and via github actions with a custom bitcoind version. The docker images are 
created for bitcoind and the original romanz/electrs electrum API server or the Blockstream/electrs 
electrum + esplora API server. The bitcoind docker image is built using a custom bitcoin repo and 
tag, as specified in the bitcoind/Dockerfile. The electrs and esplora docker images are built on 
top of the custom bitcoind image.

### Github actions

Below are examples of how to use the images created by this project in github actions jobs:

    #### electrum test job 
    ```
    test-electrum:
        name: Test Electrum
        runs-on: ubuntu-16.04
        container: bitcoindevkit/electrs:<version>
        env:
          BDK_RPC_AUTH: USER_PASS
          BDK_RPC_USER: admin
          BDK_RPC_PASS: passw
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
          BDK_RPC_AUTH: USER_PASS
          BDK_RPC_USER: admin
          BDK_RPC_PASS: passw
          BDK_RPC_URL: 127.0.0.1:18443
          BDK_RPC_WALLET: bdk-test
          BDK_ELECTRUM_URL: tcp://127.0.0.1:60401
          BDK_ESPLORA_URL: http://127.0.0.1:3002
        ...
    ```
    
### Local `bdk` testing

Below is an example of how to run `bdk` electrum tests locally using the electrs docker image:

   ```shell
    # start the electrs docker container
    docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs
   
    # in new shell from the `bdk` project repo directory run electrum integration tests
    export BDK_RPC_AUTH=USER_PASS
    export BDK_RPC_USER=admin
    export BDK_RPC_PASS=passw
    export BDK_RPC_URL=127.0.0.1:18443
    export BDK_RPC_WALLET=bdk-test
    export BDK_ELECTRUM_URL=tcp://127.0.0.1:60401
    
    cargo test --features test-electrum --no-default-features
    
    # kill the electrs container when you're done
    docker kill electrs
   ```
   
### Local `bdk-cli` testing

Below is an example of how to test `bdk-cli` with electrum or esplora server APIs locally using the 
esplora docker image:

    ```shell
    # start esplora docker container
    docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp -p 127.0.0.1:3002:3002/tcp --name esplora bitcoindevkit/esplora
    
    # in a new shell sync wallet via the electrum APIs
    bdk-cli -n regtest wallet --server tcp://127.0.0.1:60401 --descriptor "wpkh(tpubEBr4i6yk5nf5DAaJpsi9N2pPYBeJ7fZ5Z9rmN4977iYLCGco1VyjB9tvvuvYtfZzjD5A8igzgw3HeWeeKFmanHYqksqZXYXGsw5zjnj7KM9/*)" sync     
    
    # or sync wallet via the esplora APIs
    bdk-cli -n regtest wallet --esplora http://127.0.0.1:3002 --descriptor "wpkh(tpubEBr4i6yk5nf5DAaJpsi9N2pPYBeJ7fZ5Z9rmN4977iYLCGco1VyjB9tvvuvYtfZzjD5A8igzgw3HeWeeKFmanHYqksqZXYXGsw5zjnj7KM9/*)" sync
    
    # kill the esplora container when you're done
    docker kill esplora   
    ```
  
### Create aliases with the electrs container for local regtest electrum testing

   ```shell
   alias elstart='docker run -d --rm -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs'
   alias elstop='docker kill electrs'
   alias ellogs='docker container logs electrs'
   alias elcli='docker exec -it electrs /root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw $@'
   ```
   
### Use aliases with the esplora container for local regtest electrum and esplora testing

   ```shell
   alias esstart='docker run -d --rm -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp -p 127.0.0.1:3002:3002/tcp --name esplora bitcoindevkit/esplora'
   alias esstop='docker kill esplora'
   alias eslogs='docker container logs esplora'
   alias escli='docker exec -it esplora /root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw $@'
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
