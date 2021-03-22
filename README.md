### Purpose

This purpose of this project is to create bitcoind and electrs regtest docker images using a custom
bitcoin repo and branch, as specified in the bitcoind/Dockerfile. These images can be used for
github actions containers or for localhost testing. The electrs docker image is built on top of the
bitcoind image.

To use in a github actions job:

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
    
To use for local testing:

   ```shell
    export BDK_RPC_AUTH=USER_PASS
    export BDK_RPC_USER=admin
    export BDK_RPC_PASS=passw
    export BDK_RPC_URL=127.0.0.1:18443
    export BDK_RPC_WALLET=bdk-test
    export BDK_ELECTRUM_URL=tcp://127.0.0.1:60401
    
    docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs:<version>
   ```
    
   in another shell, for example from the `bdk` project repo
    
   ```shell
    cargo test --features test-electrum --no-default-features
   ```

### Build local regtest bitcoind and electrs docker images

1. Build docker containers (only needed if you don't want to use the docker hub versions)

   ```shell
   docker build -t bitcoindevkit/bitcoind:<version> bitcoind  
   docker build -t bitcoindevkit/electrs:<version> electrs
   ```
   
### Push docker images to docker hub

1. Login

   `docker login`
   
1. Push new tagged images, where <version> is new git tag for this repo

   ```shell
   docker push bitcoindevkit/bitcoind:<version>
   docker push bitcoindevkit/electrs:<version>
   ```
   
1. Build and push update `latest` image versions as needed

   ```shell
   docker build -t bitcoindevkit/bitcoind:latest bitcoind  
   docker build -t bitcoindevkit/electrs:latest electrs
   
   docker push bitcoindevkit/bitcoind:latest
   docker push bitcoindevkit/electrs:latest
   ```
   
### Run local regtest bitcoind and electrs docker images

1. Run just the bitcoind container as a detached process and remove the container when it's killed 
    
   `docker run -d --rm -p 127.0.0.1:18443-18444:18443-18444/tcp --name bitcoind bitcoindevkit/bitcoind`
   
1. Kill the bitcoind container

   `docker kill bitcoind`

1. Run the bitcoind + electrs container as a detached process and remove the container when it's killed

   `docker run -d --rm -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs`

1. Kill the bitcoind + electrs container

   `docker kill electrs`
  
### Use aliases with electrs container for local regtest testing

1. create aliases to start, stop, view logs and send cli commands to container

   ```shell
   alias rtstart='docker run -d --rm -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs'
   alias rtstop='docker kill electrs'
   alias rtlogs='docker container logs electrs'
   alias rtcli='docker exec -it electrs /root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw $@'
   ```
  
1. use aliases to start container, view logs, run cli command, stop container

   ```shell
   rtstart  
   rtlogs  
   rtcli help    
   rtcli getwalletinfo    
   rtcli getnewaddress  
   rtstop  
   ```
