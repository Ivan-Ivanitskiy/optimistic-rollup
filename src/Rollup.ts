declare let window: any;

import { ethers } from 'ethers';

// DummyDepositWithdraw contract address
const contractAddress = '0xc239e0d299420aE737A2d1C6671cEA468B2Ba325';

// A provider for a user to interact with SC
const userProvider = new ethers.providers.Web3Provider(window.ethereum, 'any');

// A provider for the operator to interact with SC
const operatorProvider = new ethers.providers.JsonRpcProvider('https://eth-sepolia.g.alchemy.com/v2/YOUR_ALCHEMY_API_KEY');

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
  try {
    // Enable MetaMask
    await window.ethereum.request({ method: 'eth_requestAccounts' });

    // Check network
    const network = await userProvider.getNetwork();
    console.log('Network:', network);

    if (network.chainId !== 11155111) {
      alert('Oi mate, switch to Sepolia testnet.');
      console.log('Not on the Sepolia testnet. Exiting...');
      return;
    }

    userSigner = userProvider.getSigner();
    userContract = new ethers.Contract(contractAddress, abi, userSigner);
    document.getElementById('connectStatus')!.textContent = 'Connected ✅';

    const address = await userSigner.getAddress();
    const balance = await userContract.balanceOf(address);
    document.getElementById('balance')!.textContent = ethers.utils.formatEther(balance);

  } catch (error) {
    console.error('An error occurred while connection a wallet:', error);
  }
});

document.getElementById('depositButton')!.addEventListener('click', async () => {
  try {
    const network = await userProvider.getNetwork();
    if (network.chainId !== 11155111) {
      alert('Oi mate, switch to Sepolia testnet.');
      console.log('Not on the Sepolia testnet. Exiting...');
      return;
    }

    const depositAmount = (document.getElementById('depositAmount') as HTMLInputElement)!.value;
    await userContract.deposit({ value: ethers.utils.parseEther(depositAmount) });
  } catch (error) {
    console.error('An error occurred while depositing:', error);
  }
});

document.getElementById('withdrawButton')!.addEventListener('click', async () => {
  try {
    const network = await userProvider.getNetwork();
    if (network.chainId !== 11155111) {
      alert('Oi mate, switch to Sepolia testnet.');
      console.log('Not on the Sepolia testnet. Exiting...');
      return;
    }

    const withdrawAmount = (document.getElementById('withdrawAmount') as HTMLInputElement)!.value;
    await userContract.withdraw(ethers.utils.parseEther(withdrawAmount));
  } catch (error) {
    console.error('An error occurred while withdrawing:', error);
  }
});

document.getElementById('transferButton')!.addEventListener('click', async () => {
  try {
    const network = await userProvider.getNetwork();
    if (network.chainId !== 11155111) {
      alert('Oi mate, switch to Sepolia testnet.');
      console.log('Not on the Sepolia testnet. Exiting...');
      return;
    }

    const transferAddress = (document.getElementById('transferAddress') as HTMLInputElement)!.value;
    const transferAmount = (document.getElementById('transferAmount') as HTMLInputElement)!.value;
    // TODO: replace the first argument with the address of the user
    await operatorContract.transferFrom(operatorWallet.getAddress(), transferAddress, ethers.utils.parseEther(transferAmount));
  } catch (error) {
    console.error('An error occurred while transferring:', error);
  }
});
