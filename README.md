# buidl-asset-tokenisation

## Context

Asset Tokenisation Example powered by SettleMint

---

## Technical Details

---

## Get Started

1. Create an account on SettleMint [here](https://console.settlemint.com/)
2. Create an Organisation (e.g. Your_Name_Organisation)
3. Create an Application (e.g. Your_Name_Application)
4. Click on Blockchain networks and add a `Hyperledger Besu` permissioned network and a node (e.g. Your_Name_Network, Your_Name_Node)
5. Click on Storage and add a `IPFS (decentralised)` storage
6. Click on Private keys and add a `Accessible EC DSA P256` key
7. Click on Smart Contracts sets and add a `Empty` template (e.g. Your_Name_Asset_Tokenisation)

### Setting up your Smart Contract

1. Click on your deployed smart contract set and go to the IDE tab and click `view in fullscreen mode`
2. Copy the template `AssetTokenisation.sol` found in `./Smart-Contracts` and paste it in the IDE's folder `./contracts`
3. In the folder `./deploy`, open the file named `00_deploy_example.ts` and in line 13, change the name of the contract depending on your file name

```javascript
  await deploy('AssetTokenisation', {
    from: deployer,
    args: [],
    log: true,
  });
```

4. In the root folder, open the file named `hardhat.config.ts` and in line 34, change the Solidity version to 0.8.13

```js
  solidity: {
    version: '0.8.13',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: 'istanbul',
    },
  }
```

### BUIDL Session

1. Deploy your Asset Tokenisation smart contract!

```bash
pnpm run smartcontract:deploy
```

---
# buidl-asset-tokenisation
