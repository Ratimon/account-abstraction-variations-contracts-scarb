## Account Abstraction variations

### Installation

We assume that you already setup your working environment with [scarb](https://docs.swmansion.com/scarb/), [starkli](https://book.starkli.rs/installation), and  [dojo](https://book.dojoengine.org/getting-started/quick-start.html) 

### Quick Start

1. Compiling to sierra

```sh
scarb --version
```

```sh
scarb build
```

Then, the compiled file will be generated at **/target/dev/<name>.sierra.json**. This file will be used during deployment process.

2. Running Test

```sh
scarb cairo-test
```

3. Running local node (**katana**)

```sh
make katana-node
```

4. Preparing Smart Wallets

First, create the default directory:

```sh
mkdir ~/.starkli-wallets/deployer -p
```

Then generate the keystore file.

```sh
starkli signer keystore new  ~/.starkli-wallets/deployer/my_keystore_1.json
```
Or use the (recovered) **private key** from the output of the initial  **katana** or   **Argent** 's export:

```sh
starkli signer keystore from-key ~/.starkli-wallets/deployer/my_keystore_1.json
Enter private key:
Enter password:
```

Then, create the Account Descriptor:

```sh
touch ~/.starkli-wallets/deployer/account1_account.json
```

The Account Descriptor will look like this. :

```json
{
  "version": 1,
  "variant": {
        "type": "open_zeppelin",
        "version": 1,
        "public_key": "<SMART_WALLET_PUBLIC_KEY>"
  },
    "deployment": {
        "status": "deployed",
        "class_hash": "<SMART_WALLET_CLASS_HASH>",
        "address": "<SMART_WALLET_ADDRESS>"
  }
}
```

The **public key** can be retrieved from the output of the initial **katana** command or **starkli**

```sh
starkli signer keystore inspect ~/.starkli-wallets/deployer/account1_keystore.json
```

The **address** can be found from the output of the initial **katana** command or **Argent**

The **smart wallet class hash** (same for all you smart wallets) can be retrieved via:

```sh
starkli class-hash-at <SMART_WALLET_ADDRESS> --rpc <RPC>
```

> **Note**💡

> <SMART_WALLET_ADDRESS> for **katana** is:

```sh
http://0.0.0.0:5050
```

4. Deploy contract

Declare the contract to get the **class hash**, if it is already deployed, it can be found via any **explorer**

```sh
make declare
```

Use the resulting **class hash** and [Argument resolution](https://book.starkli.rs/argument-resolution) as parameters when deploying contract

```sh
make deploy
```