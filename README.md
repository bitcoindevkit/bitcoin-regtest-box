# Purpose

The purpose of this project is to create a localhost bitcoin regtest network using a custom bitcoin repo and branch, as specified in the Dockerfile.

<br />

### Prerequisites

To enable the regtest network, you'll need [Docker](https://www.docker.com/) installed and running on your machine.

Docker creates _containers_. Containers are self-sufficient, isolated from one another, and bundle their own software, libraries, and configuration files. Containers are great tools for the purpose of setting up regtest networks because they frontload the work of configuring and putting together the necessary software for given tasks; they are easy to configure and behave predictably on a very diverse range of operating systems.

The following commands create two containers on your local machine, complete with all necessary software for running a bitcoin regtest network. You can then tap into this network for your bitcoin testing needs.

<br />

### Start local bitcoind (regtest) nodes

Create and start two docker containers:

```bash
# create the image
$ docker-compose build

# fire up the two containers
$ docker-compose up

# shut down the containers
$ docker-compose down
```

<br />

### Connect to and control nodes

#### 1. View running containers

```bash
$ docker ps
```

#### 2. Interact with your network

If you do not have `bitcoin-cli` installed outside of docker, you can use the following commands to access the shell from one of the two containers and use `bitcoin-cli` from there:

```bash
$ docker exec -it bitcoind_1 bash
$ docker exec -it bitcoind_2 bash
```

Use `bitcoin-cli` to `getblockchaininfo`, `getnewaddress`, `generatetoaddress`, `getwalletinfo`, etc.

```bash
bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getblockchaininfo

bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getnewaddress

bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass generatetoaddress 100 <newaddress>

bitcoin-cli -regtest -rpcuser=user -rpcpassword=pass getwalletinfo
```

**_Note_**: If you are using `bitcoin-cli` outside of a docker container:

- bitcoind_1: `rpcport=18443` (default for regtest)
- bitcoind_2: `rpcport=18554`
