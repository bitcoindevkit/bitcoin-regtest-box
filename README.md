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

1. Run just the bitcoind container
    
   `docker run -p 127.0.0.1:18443-18444:18443-18444/tcp --name bitcoind bitcoindevkit/bitcoind`
   
1. Kill and remove the bitcoind container

   `docker container rm --force bitcoind`

1. Run the bitcoind + electrs container

   `docker run -p 127.0.0.1:18443-18444:18443-18444/tcp -p 127.0.0.1:60401:60401/tcp --name electrs bitcoindevkit/electrs`

1. Kill and remove the bitcoind + electrs container

   `docker container rm --force electrs`
  
### Run bitcoin-cli command from bitcoind or electrs containers
  
1. Exec shell in a running docker container 

   `docker exec -it bitcoind bash` 
   
   or
   
   `docker exec -it electrs bash`
   
1. Run `bitcoin-cli` commands from docker exec shell
   
   ```shell
   export GENERATE_ADDR=\`/root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw getnewaddress\` 
   /root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw generatetoaddress 10 $GENERATE_ADDR
   /root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw getwalletinfo
   ```
   etc.