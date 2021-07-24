#!/bin/bash

echo -e "\nStarting bitcoin node.\n"
/root/bitcoind -regtest -server -daemon -fallbackfee=0.0002 -rpcallowip=0.0.0.0/0 -rpcbind=0.0.0.0 -blockfilterindex=1 -peerblockfilters=1

echo -e "\nWaiting for bitcoin node.\n"
until /root/bitcoin-cli -regtest -datadir=/root/.bitcoin getblockchaininfo; do
    sleep 1
done
echo -e "\nCreate bdk-test wallet.\n"
/root/bitcoin-cli -regtest -datadir=/root/.bitcoin createwallet bdk-test

echo -e "\nGenerating 150 bitcoin blocks.\n"
ADDR=$(/root/bitcoin-cli -regtest -datadir=/root/.bitcoin -rpcwallet=bdk-test getnewaddress)
/root/bitcoin-cli -regtest -datadir=/root/.bitcoin generatetoaddress 150 $ADDR

echo -e "\nStarting electrs node.\n"
/root/electrs --network regtest --cookie-file /root/.bitcoin/regtest/.cookie --txid-limit 0 -vvv --jsonrpc-import
