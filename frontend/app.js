// Library to use — ethers.js v6 via CDN, no npm needed
// <script src="https://cdnjs.cloudflare.com/ajax/libs/ethers/6.7.0/ethers.umd.min.js"></script>

const VAULTWISE_ADDRESS = "0xde8365dAF3CFdF952E2F946F19a4DcAcd57eFf0F";
const USDC_ADDRESS      = "0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582";

// 1. Connect wallet
const provider = new ethers.BrowserProvider(window.ethereum);
const signer   = await provider.getSigner();

// 2. Create contract instances
const vaultWise = new ethers.Contract(VAULTWISE_ADDRESS, VAULTWISE_ABI, signer);
const usdc      = new ethers.Contract(USDC_ADDRESS, USDC_ABI, signer);

// 3. Create vault — goalAmount and duration in wei units
// USDC has 6 decimals: $500 = ethers.parseUnits("500", 6)
// Duration in seconds: 30 days = 30 * 24 * 60 * 60 = 2592000
const tx = await vaultWise.createVault(
    ethers.parseUnits("500", 6),  // $500 goal
    2592000n                       // 30 days
);
await tx.wait();

// 4. Deposit — must approve first, then deposit
const approveTx = await usdc.approve(VAULTWISE_ADDRESS, ethers.parseUnits("100", 6));
await approveTx.wait();
const depositTx = await vaultWise.deposit(0, ethers.parseUnits("100", 6));
await depositTx.wait();

// 5. Invest — sends funds to Aave, triggers Kwala → Telegram
const investTx = await vaultWise.invest(0);
await investTx.wait();

// 6. Read vault data
const vault = await vaultWise.getVault(0);
console.log("Balance:", ethers.formatUnits(vault.balance, 6), "USDC");
console.log("Invested:", vault.invested);
console.log("Goal:", ethers.formatUnits(vault.goalAmount, 6), "USDC");

// 7. Get all vault IDs for a user
const vaultIds = await vaultWise.getUserVaults(userAddress);

// 8. Withdraw
const withdrawTx = await vaultWise.withdraw(0, ethers.parseUnits("100", 6));
await withdrawTx.wait();