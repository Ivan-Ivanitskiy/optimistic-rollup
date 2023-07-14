declare let window: any;

import { ethers } from 'ethers';

// DummyDepositWithdraw contract address
const contractAddress = '0xc239e0d299420aE737A2d1C6671cEA468B2Ba325';

// A provider for a user to interact with SC
const userProvider = new ethers.providers.Web3Provider(window.ethereum, 'any');

// A provider for the operator to interact with SC
const operatorProvider = new ethers.providers.JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/8QZPGpnOqdDSiyCbmr21NdZ4Xm3NOMKG');

// Add the private key of the new Ethereum account
const operatorPrivateKey = '0x02546d588109dc9c81977df713ad43daa1732952d707cefa2b0dd0a069c9fb44';
const operatorAddress = '0xa3ac2d309203c34973769178db8b082d08ec7c0f'
const operatorWallet = new ethers.Wallet(operatorPrivateKey, operatorProvider);

const abi = [
  "function balanceOf(address account) view returns (uint256)",
  "function deposit() public payable",
  "function withdraw(uint wad)",
  "function transferFrom(address src, address dst, uint wad) public returns (bool)"
];

let userSigner: ethers.Signer;
let userContract: ethers.Contract;
const operatorContract = new ethers.Contract(contractAddress, abi, operatorWallet); 

document.getElementById('connectWallet')!.addEventListener('click', async () => {
  await window.ethereum.enable();
  userSigner = userProvider.getSigner();
  userContract = new ethers.Contract(contractAddress, abi, userSigner);
  document.getElementById('connectStatus')!.textContent = 'Connected ✅';

  const balance = await userContract.balanceOf(userSigner.getAddress());
  document.getElementById('balance')!.textContent = ethers.utils.formatEther(balance);
});

document.getElementById('depositButton')!.addEventListener('click', async () => {
  const depositAmount = (document.getElementById('depositAmount') as HTMLInputElement)!.value;
  await userContract.deposit({ value: ethers.utils.parseEther(depositAmount) });
});

document.getElementById('withdrawButton')!.addEventListener('click', async () => {
  const withdrawAmount = (document.getElementById('withdrawAmount') as HTMLInputElement)!.value;
  await userContract.withdraw(ethers.utils.parseEther(withdrawAmount));
});

document.getElementById('transferButton')!.addEventListener('click', async () => {
  const transferAddress = (document.getElementById('transferAddress') as HTMLInputElement)!.value;
  const transferAmount = (document.getElementById('transferAmount') as HTMLInputElement)!.value;
  // TODO: replace the first argument with the address of the user
  await operatorContract.transferFrom(operatorWallet.getAddress(), transferAddress, ethers.utils.parseEther(transferAmount));
});
