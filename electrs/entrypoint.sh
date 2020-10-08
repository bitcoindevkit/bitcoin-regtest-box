#!/bin/bash

echo -e "\nStarting bitcoin node.\n"
/root/bitcoind -regtest -server -daemon -fallbackfee=0.0002 -rpcuser=admin -rpcpassword=passw -rpcallowip=0.0.0.0/0 -rpcbind=0.0.0.0

echo -e "\nWaiting for bitcoin node.\n"
until /root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw getblockchaininfo; do
    sleep 1
done

echo -e "\nGenerating 150 bitcoin blocks.\n"
ADDR=$(/root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw getnewaddress)
/root/bitcoin-cli -regtest -rpcuser=admin -rpcpassword=passw generatetoaddress 150 $ADDR

echo -e "\nStarting electrs node.\n"
/root/electrs --network regtest -vvv --jsonrpc-import