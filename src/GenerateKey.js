const Wallet = require('ethereumjs-wallet').default;
const wallet = Wallet.generate();

console.log("Address: " + wallet.getAddressString());
console.log("Private Key: " + wallet.getPrivateKeyString());
