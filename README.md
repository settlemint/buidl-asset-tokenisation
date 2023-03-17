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

5. Deploy your Asset Tokenisation smart contract! Please take down of your deployed smart contract address.

```bash
pnpm run smartcontract:deploy
```

### BUIDL Session

1. In the SettleMint BPass Platform, click on your profile icon at the top right at click on `API keys`
2. Generate your API key and note it down
3. Head back to your application, click on `Blockchain nodes`, click on your deployed node and click on `Connect`
4. Note down your `JSON-RPC` endpoint
5. Now, click on `Integration tools` and deploy an `Integration Studio` tool.
6. Click on your deployed `Integration Studio`, click on `Interface` and click `view in fullscreen mode`
7. At the top right dropdown box, click on `Import` and import the `flows.json` found in the `Integration-Studio` directory
8. Once imported, click on the `Blockchain APIs` tab and double click on the `Set Global Variables` module
9. Go to the `On Message` tab and edit your noted down variables and click `Done`

```javascript
    key: 'bpass-...',
    rpcEndpoint: 'https://...',
    contract: '0x...',
```

10. Now, click on `Deploy`
---
