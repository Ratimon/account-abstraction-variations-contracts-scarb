# ERC20 variations

## Installation

We assume that you already setup your working environment with [scarb](https://docs.swmansion.com/scarb/), [starkli](https://book.starkli.rs/installation), [starknet-foundry](https://foundry-rs.github.io/starknet-foundry/getting-started/installation.html) and  [dojo](https://book.dojoengine.org/getting-started/quick-start.html) 

## Quick Start

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

> **Note**💡

> It is recommended to use [asdf]( https://asdf-vm.com/) as a package manager, so it is easier to manage dependencies:

```sh
asdf exec scarb --version
```

3. Running local node (**katana**)

```sh
make katana-node
```

4. Preparing Smart Wallets and relevant environment vatiables

First, create the default directory:

```sh
mkdir ~/.starkli-wallets/deployer
```

Then generate the keystore file.

```sh
starkli signer keystore new  ~/.starkli-wallets/deployer/my_keystore_1.json
```
Or use the (recovered) **private key** from the output of the initial  **katana** or   **Argent** 's export:

```sh
starkli signer keystore from-key ~/.starkli-wallets/deployer/account1_keystore.json
Enter private key:
Enter password:
```

Then, create OZ's Account Descriptor:

```sh
starkli account oz init ~/.starkli-wallets/deployer/account1_account.json
```

Alternatively, we could create customized Account Descriptor:

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
        "public_key": "<SMART_WALLET_PUBLIC_KEY>",
        "legacy": false
  },
    "deployment": {
        "status": "undeployed",
        "class_hash": "<SMART_WALLET_CLASS_HASH>",
        // "address": "<SMART_WALLET_ADDRESS>", // in case the contract is already deployed
        "salt": "<SALT>" // in case the contract is not deployed yet
  }
}
```

The **<SMART_WALLET_PUBLIC_KEY>** can be retrieved from the output of the initial **katana** command or **starkli**

```sh
starkli signer keystore inspect ~/.starkli-wallets/deployer/account1_keystore.json
```

The **<SMART_WALLET_ADDRESS>** can be found from the output of the initial **katana** command or your existing account

The **<CONTRACT_CLASS_HASH>** (same for all your smart wallets) can be retrieved via:

```sh
starkli class-hash-at <SMART_WALLET_ADDRESS> --rpc <RPC>
```

Now, we could even config environment variable in `envars.sh`:

```sh
export STARKNET_KEYSTORE=~/.starkli-wallets/deployer/account1_keystore.json
export STARKNET_ACCOUNT=~/.starkli-wallets/deployer/account1_account.json
export STARKNET_RPC=<RPC>
```

> **Note**💡

> <RPC> for **katana** is:

```sh
http://0.0.0.0:5050
```

We can activate it via:

```sh
source ~/.starkli-wallets/deployer/envars.sh
```

Finally, we can deploy the account with specified keystore, account and network:

```sh
starkli account deploy ~/.starkli-wallets/deployer/account1_account.json
```
If successful, your `account1_account.json` will be updated.

> **Note**💡

> Sometimes, we could recreate the account file from on-chain data alone. This could be helpful when the account file is lost or deployment process is interupted or not succesfull:

```sh
starkli account fetch <ADDRESS> --output ~/.starkli-wallets/deployer/account1_account.json
```


5. Deploy contract

Declare the contract to get the **<CONTRACT_CLASS_HASH>**, if it is already deployed, it can be found via any **explorer**

```sh
starkli declare target/dev/erc20_variations_ERC20WithSanction.sierra.json --compiler-version 2.1.0
```

Use the resulting **<CONTRACT_CLASS_HASH>** and [Argument resolution](https://book.starkli.rs/argument-resolution) as parameters when deploying contract

```sh
starkli deploy <CONTRACT_CLASS_HASH> str:NAME str:SYMBOL <PARAM_OWNER_ADDRESS>
```