const VAULTWISE_ABI = [
  {
    "type": "constructor",
    "inputs": [
      { "name": "_usdc", "type": "address" },
      { "name": "_aavePool", "type": "address" }
    ]
  },
  {
    "type": "function",
    "name": "createVault",
    "inputs": [
      { "name": "goalAmount", "type": "uint256" },
      { "name": "duration", "type": "uint256" }
    ],
    "outputs": [{ "name": "vaultId", "type": "uint256" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "deposit",
    "inputs": [
      { "name": "vaultId", "type": "uint256" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "invest",
    "inputs": [{ "name": "vaultId", "type": "uint256" }],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "withdraw",
    "inputs": [
      { "name": "vaultId", "type": "uint256" },
      { "name": "amount", "type": "uint256" }
    ],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getVault",
    "inputs": [{ "name": "vaultId", "type": "uint256" }],
    "outputs": [{
      "name": "",
      "type": "tuple",
      "components": [
        { "name": "owner",      "type": "address" },
        { "name": "goalAmount", "type": "uint256" },
        { "name": "balance",    "type": "uint256" },
        { "name": "createdAt",  "type": "uint256" },
        { "name": "duration",   "type": "uint256" },
        { "name": "invested",   "type": "bool"    },
        { "name": "exists",     "type": "bool"    }
      ]
    }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getUserVaults",
    "inputs": [{ "name": "user", "type": "address" }],
    "outputs": [{ "name": "", "type": "uint256[]" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "getUsdc",
    "inputs": [],
    "outputs": [{ "name": "", "type": "address" }],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "VaultCreated",
    "inputs": [
      { "name": "owner",      "type": "address", "indexed": true  },
      { "name": "vaultId",    "type": "uint256", "indexed": true  },
      { "name": "goalAmount", "type": "uint256", "indexed": false },
      { "name": "duration",   "type": "uint256", "indexed": false }
    ]
  },
  {
    "type": "event",
    "name": "Deposited",
    "inputs": [
      { "name": "owner",      "type": "address", "indexed": true  },
      { "name": "vaultId",    "type": "uint256", "indexed": true  },
      { "name": "amount",     "type": "uint256", "indexed": false },
      { "name": "newBalance", "type": "uint256", "indexed": false }
    ]
  },
  {
    "type": "event",
    "name": "Invested",
    "inputs": [
      { "name": "owner",   "type": "address", "indexed": true  },
      { "name": "vaultId", "type": "uint256", "indexed": true  },
      { "name": "amount",  "type": "uint256", "indexed": false }
    ]
  },
  {
    "type": "event",
    "name": "WithdrawRequested",
    "inputs": [
      { "name": "owner",   "type": "address", "indexed": true  },
      { "name": "vaultId", "type": "uint256", "indexed": true  },
      { "name": "amount",  "type": "uint256", "indexed": false }
    ]
  }
];

const USDC_ABI = [
  {
    "type": "function",
    "name": "approve",
    "inputs": [
      { "name": "spender", "type": "address" },
      { "name": "amount",  "type": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "bool" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "balanceOf",
    "inputs": [{ "name": "account", "type": "address" }],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "decimals",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint8" }],
    "stateMutability": "view"
  }
];