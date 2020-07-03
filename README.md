### Purpose

This purpose of this project is to create a localhost bitcoin regtest network using a custom
bitcoin repo and branch, as specified in the Dockerfile.

### Start local bitcoind (regtest) nodes

1. Create and start docker containers

   `$ docker-compose build`  
   `$ docker-compose up`

### Connect to and Control Nodes

1. view docker running containers

   `$ docker ps`
  
1. exec shell in running docker node (optional, if you don't have bitcoin-cli installed outside of docker)

   `$ docker exec -it bitcoind_1 bash` or  
   `$ docker exec -it bitcoind_2 bash`
  
1. use bitcoin-cli to getblockchaininfo, getnewaddress, generatetoaddress, getwalletinfo, etc.  
   
   if using bitcoin-cli outside of docker container:  
   - bitcoind_1: rpcport=18443 (default for regtest)
   - bitcoind_2: rpcport=18554  
  
   `# bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getblockchaininfo`
   
   `# bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getnewaddress`
   
   `# bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass generatetoaddress 100 <newaddress>`
   
   `# bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getwalletinfo`