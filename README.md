# fabric-cloud-init

Experimental cloud config to set up a Fabric development environment which is intended to work on both amd64 and arm64 architectures.

**Important:** Due to the lack of arm64 based Fabric docker images, the only option for running smart contracts on arm64 is to use the nano test network and the chaincode as a service (CCaaS) builder.

## Usage

```shell
multipass launch \
  --name        fabric-dev \
  --disk        80G \
  --cpus        8 \
  --mem         8G \
  --cloud-init  devenv-cloud-config.yaml
```

And then...

```shell
multipass shell fabric-dev
```

And then...

```shell
setup-fabric
```

No and then...

Everything should be ready to start developing and testing Fabric chaincode!

## Running chaincode as a service

First, change to the nano test network directory.

```shell
cd ~/fabric-samples/test-network-nano-bash/
```

Next, start the Fabric network.

```shell
./network.sh start
```

Open another terminal, and shell in to the `fabric-dev` VM again.

```shell
multipass shell fabric-dev
```

Make sure you're in the nano test network directory.

```shell
cd ~/fabric-samples/test-network-nano-bash/
```

Set up the environment to run `peer` commands against `peer1`.

```shell
. ./peer1admin.sh
```

Create a CCaaS package.

```shell
pkgccaas -l devcc -a 127.0.0.1:9999
```

Install the CCaaS package.

```shell
peer lifecycle chaincode install devcc.tgz
```

Export a PACKAGE_ID environment variable for use in the following commands.

```shell
export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid devcc.tgz) && echo $PACKAGE_ID
```

Note: the PACKAGE_ID must match the chaincode code package identifier shown by the peer lifecycle chaincode install command.

Approve the chaincode.

```shell
peer lifecycle chaincode approveformyorg -o 127.0.0.1:6050 --channelID mychannel --name dev-contract --version 1 --package-id $PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
```

Commit the chaincode.

```shell
peer lifecycle chaincode commit -o 127.0.0.1:6050 --channelID mychannel --name dev-contract --version 1 --sequence 1 --tls --cafile "${PWD}"/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
```

Everything is configured but now you actually need to run some chaincode for Fabric to connect to!
Open another new terminal, and shell in to the `fabric-dev` VM again.

```shell
multipass shell fabric-dev
```

Change to the a suitable chaincode source directory, e.g.

```shell
cd ~/fabric-samples/asset-transfer-basic/chaincode-go/
```

Export a `CORE_CHAINCODE_ID_NAME` environment variable, which is required to run chaincode as a service.
This is the same as the `PACKAGE_ID` in previous steps.
[TODO: don't include the value here?]

```shell
export CORE_CHAINCODE_ID_NAME=devcc:f357d81429a6a2fe63708d257e18e9c35dfe06c6b073c85b4baa65b0b4f159cb
```

Export a `CHAINCODE_SERVER_ADDRESS` environment variable, which is the address the chaincode will run at.

```shell
export CHAINCODE_SERVER_ADDRESS=0.0.0.0:9999
```

Update the chaincode to the latest version of `fabric-contract-api-go`.
[TODO: fix this!]

```shell
go get -u github.com/hyperledger/fabric-contract-api-go
go mod tidy
```

Start the chaincode!

```shell
go run assetTransfer.go
```

To run transactions, switch back to the terminal you used to run the `peer` commands.

For example, query the chaincode metadata.

```shell
peer chaincode query -C mychannel -n dev-contract -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}'
```

## Work in progress

Nothing to see here!

Would a specific fabric user with ssh access be useful? (TBC)

```yaml
users:
  - name: fabdev
    lock_passwd: false
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    groups: sudo
    shell: /bin/bash

chpasswd:
  expire: true
  users:
    - name: fabdev
      type: RANDOM

runcmd:
  - sed -i -e '/^Port/s/^.*$/Port 4444/' /etc/ssh/sshd_config
  - sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
  - sed -i -e '$aAllowUsers demo' /etc/ssh/sshd_config
  - restart ssh
```

Git clone or download source tarball?

```shell
wget -O fabric.tar.gz https://github.com/hyperledger/fabric/archive/refs/tags/v2.4.6.tar.gz

git clone --depth 1 --branch release-2.4 https://github.com/hyperledger/fabric.git
```

Cannot use `make release` because Fabric Makefile doesn't include arm in release platforms...

```
RELEASE_PLATFORMS = darwin-amd64 linux-amd64 windows-amd64 linux-arm64
```

What's up with Go? It keeps complaining that `warning: GOPATH set to GOROOT (/usr/local/go) has no effect` which doesn't appear to be true! At least I've not found another way to get the binaries installed in the right place yet!

```
GOMODCACHE=/usr/local/go/pkg/mod GOCACHE=/root/.cache/go-build
```


CCAAS...


peer lifecycle chaincode install conga-nft.tgz
export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid conga-nft.tgz) && echo $PACKAGE_ID

peer lifecycle chaincode approveformyorg -o 127.0.0.1:6050 --channelID mychannel --name sample-contract --version 1 --package-id $PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

peer lifecycle chaincode commit -o 127.0.0.1:6050 --channelID mychannel --name sample-contract --version 1 --sequence 1 --tls --cafile "${PWD}"/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

peer chaincode query -C mychannel -n sample-contract -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}'



K8s..

kind create cluster

kubectl cluster-info --context kind-kind

export KUBECONFIG_PATH=$HOME/.kube/config

ip addr show docker0 <- didn't work!

docker network inspect kind

jq to extract Gateway?

Find/replace CCADDR with the default gateway in the four peerX.sh scripts, e.g. 172.18.0.1

./network.sh start

New terminal in nano test network dir...

cd ~/fabric-samples/test-network-nano-bash/

. ./peer1admin.sh

```
curl -fsSL \
  https://github.com/hyperledgendary/conga-nft-contract/releases/download/v0.1.3/conga-nft-contract-v0.1.3.tgz \
  -o conga-nft.tgz
```

peer lifecycle chaincode install conga-nft.tgz

export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid conga-nft.tgz) && echo $PACKAGE_ID

peer lifecycle chaincode approveformyorg -o 127.0.0.1:6050 --channelID mychannel --name sample-contract --version 1 --package-id $PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

peer lifecycle chaincode commit -o 127.0.0.1:6050 --channelID mychannel --name sample-contract --version 1 --sequence 1 --tls --cafile "${PWD}"/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

peer chaincode query -C mychannel -n sample-contract -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}'


