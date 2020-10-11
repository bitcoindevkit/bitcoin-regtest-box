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
        container: bitcoindevkit/electrs
        env:
          MAGICAL_RPC_AUTH: USER_PASS
          MAGICAL_RPC_USER: admin
          MAGICAL_RPC_PASS: passw
          MAGICAL_RPC_URL: 127.0.0.1:18443
          MAGICAL_ELECTRUM_URL: tcp://127.0.0.1:60401
        ...
   ```
    
To use for local testing:

   ```shell
    export MAGICAL_RPC_AUTH=USER_PASS
    export MAGICAL_RPC_USER=admin
    export MAGICAL_RPC_PASS=passw
    export MAGICAL_RPC_URL=127.0.0.1:18443
    export MAGICAL_ELECTRUM_URL=tcp://127.0.0.1:60401
    
    docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs
   ```
    
   in another shell, for example from the `bdk` project repo
    
   ```shell
    cargo test --features test-electrum --no-default-features
   ```

### Build local regtest bitcoind and electrs docker images

1. Build docker containers (only needed if you don't want to use the docker hub versions)

   ```shell
   docker build -t bitcoindevkit/bitcoind bitcoind  
   docker build -t bitcoindevkit/electrs electrs
   ```
   
### Push docker images to docker hub

1. Login

   `docker login`
   
1. Push images

   ```shell
   docker push bitcoindevkit/bitcoind
   docker push bitcoindevkit/electrs
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