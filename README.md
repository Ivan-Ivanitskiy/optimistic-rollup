# Optimisctic Rollup Mockup

Oi mate! This is the project for me to learn to code (Solidity, Typescript, Python), and for me and you to understand how Optimistic Rollup work. 

If you need to learn more theory on what it is, please refer to [this article](https://www.alchemy.com/overviews/optimistic-rollups). Make sure to follow the links, as well, for they are super useful.

In this project I obviously don't implement the EVM on L2, but rather just simple transfers. Still, that seems to be perfect to showcase the Optimistic Rollup mechanics.

## Current state

Currently, there are:

- Optimistic Rollup smart contract contracts, that are not even finished; still, readable
- DummyDepositWithdrawal smart contract, deployed on Sepolia testnet [here](https://sepolia.etherscan.io/address/0xc239e0d299420aE737A2d1C6671cEA468B2Ba325) for me to test some frontend
- some mockup frontend (index.html, src/Rullup.ts) to emulate deposits and withdrawals of funds to L2
- workpiece backend which is just an initiated Django project

## Security

In the current state, security is non-existens, since I stored the Ethereum private key (and the Alchemy API key) for the DummyDepositWithdrawal operator in src/Rullup.ts file in plain text and also pushed it to GitHub. Never use PKs in the frontend; never store them in plaintext; never push them to version control tools.

However, this setup allows you to play around with the mockup frontend without:

- deploying you own contract
- generating and storing your own Operator PK
- and depositing SepoliaETH there

So, I took the shot for both of us, innit? :) You will need your own Alchemy API key tho.

## Build and run

The dummy smart contract is already deployed, so you don't need to build it. The backend is not there yet, so you don't need to build that either.

To build and run the frontend, first replace YOUR_ALCHEMY_API_KEY with your actual Alchemy API key (you can get one for free). Then run:

```shell
npm install
npx webpack --config webpack.config.js
npx http-server . -o index.html
```
