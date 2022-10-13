# fabric-cloud-init

Experimental cloud config to set up a Fabric environment

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
sudo setup-fabric
```

## Work in progress

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

```
curl -fsSL \
  https://github.com/hyperledgendary/conga-nft-contract/releases/download/v0.1.3/conga-nft-contract-v0.1.3.tgz \
  -o conga-nft.tgz
```

OR ccaas package TBC


peer lifecycle chaincode install conga-nft.tgz
export PACKAGE_ID=$(peer lifecycle chaincode calculatepackageid conga-nft.tgz) && echo $PACKAGE_ID

peer lifecycle chaincode approveformyorg -o 127.0.0.1:6050 --channelID mychannel --name sample-contract --version 1 --package-id $PACKAGE_ID --sequence 1 --tls --cafile ${PWD}/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

peer lifecycle chaincode commit -o 127.0.0.1:6050 --channelID mychannel --name sample-contract --version 1 --sequence 1 --tls --cafile "${PWD}"/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt

peer chaincode query -C mychannel -n sample-contract -c '{"Args":["org.hyperledger.fabric:GetMetadata"]}'
