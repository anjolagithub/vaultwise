
---

```markdown
# VaultWise 🏦

> On-chain USDC savings vault with automated Aave V3 yield, powered by Kwala

Built for the **Build with Kwala Hackathon — April 23–24, 2026**

---

## 🚀 Overview

VaultWise helps everyday users save in USDC and earn DeFi yield automatically — without needing to understand how DeFi works.

### The Problem
Salaried workers in Nigeria lose **30%+ of savings value yearly** due to inflation. While DeFi platforms offer yield, they are:
- Complex
- Multi-step
- Not beginner-friendly

### The Solution
VaultWise simplifies everything:

> **Create a goal → Deposit USDC → Click Invest**

Kwala automates:
- Supplying funds to Aave
- Tracking yield
- Sending notifications

No DeFi knowledge required.

---

## 🌐 Live Deployment

| Item | Value |
|------|------|
| Network | Polygon Amoy Testnet (ChainID 80002) |
| Contract | `0xde8365dAF3CFdF952E2F946F19a4DcAcd57eFf0F` |
| USDC | `0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582` |
| Aave Pool | `0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951` |
| Explorer | https://amoy.polygonscan.com/address/0xde8365dAF3CFdF952E2F946F19a4DcAcd57eFf0F |

---

## 🏗 Architecture

```

User (Frontend)
│
▼
VaultWise.sol ───── emits events ─────▶ Kwala Workflows
│                                      │
│ holds USDC                           │ sends Telegram notifications
│ calls Aave on invest()               ▼
▼                               Telegram Bot
Aave V3 Pool
(user receives aUSDC)

```

### Key Design Principles
- Non-custodial (users retain control)
- No backend server
- Smart contract is intentionally minimal
- Kwala handles automation + notifications

---

## 📁 Project Structure

```

vaultwise/
├── src/
│   └── VaultWise.sol
├── script/
│   ├── DeployVaultWise.s.sol
│   └── HelperConfig.s.sol
├── test/
│   ├── unit/
│   │   └── VaultWiseTest.t.sol
│   └── mocks/
│       └── MockAavePool.sol
├── frontend/
│   ├── index.html
│   ├── app.js
│   └── abi.js
├── kwala/
│   ├── vaultwise-invest.yaml
│   ├── vaultwise-deposit.yaml
│   └── vaultwise-withdraw.yaml
├── .env.example
├── foundry.toml
└── README.md

````

---

## 🧠 Smart Contract

### Core Functions

| Function | Description |
|----------|------------|
| `createVault(goalAmount, duration)` | Create a savings vault |
| `deposit(vaultId, amount)` | Deposit USDC |
| `invest(vaultId)` | Supply funds to Aave |
| `withdraw(vaultId, amount)` | Withdraw or trigger withdrawal |
| `getVault(vaultId)` | Fetch vault data |
| `getUserVaults(address)` | Get user vault IDs |

---

### Events (Kwala Listens)

| Event | Trigger | Action |
|------|--------|--------|
| `VaultCreated` | createVault | — |
| `Deposited` | deposit | Telegram notification |
| `Invested` | invest | Telegram notification |
| `WithdrawRequested` | withdraw | Telegram notification |

---

## ⚡ Kwala Workflows

| Workflow | Trigger | Action |
|----------|--------|--------|
| deposit_notify | Deposited | Notify user |
| invest_notify | Invested | Confirm yield started |
| withdraw_notify | WithdrawRequested | Notify withdrawal |

---

## 🛠 Local Development

### Prerequisites
- Foundry
- Git

### Setup

```bash
git clone https://github.com/anjolagithub/vaultwise
cd vaultwise
forge install OpenZeppelin/openzeppelin-contracts
````

### Run Tests

```bash
forge test -vv
```

Expected: **10 passed, 0 failed**

---

### Deploy

```bash
cp .env.example .env

source .env
forge script script/DeployVaultWise.s.sol:DeployVaultWise \
  --rpc-url $POLYGON_AMOY_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  -vvvv
```

---

## 🖥 Frontend Integration

* Uses ethers.js v6
* Connects via MetaMask
* No backend required

### MetaMask Setup

```
Network: Polygon Amoy
RPC: https://rpc-amoy.polygon.technology
Chain ID: 80002
Symbol: POL
```

---

### Notes

* USDC = 6 decimals
* Must call `approve()` before `deposit()`
* `invest()` sends funds to Aave
* Telegram notifications triggered via Kwala

---

## 💡 Business Case

### Target Users

* Salaried workers in Africa
* Crypto-savvy but not DeFi-native

### Problem

* Inflation destroys savings
* DeFi is too complex

### Why Web3

* Non-custodial
* Permissionless yield
* No banking license required

### Monetization

* 0.5% fee on yield

### Roadmap

* Polygon mainnet
* Mobile app
* More strategies
* Fiat on-ramp

---

## 👥 Team

Built for the Kwala Hackathon

| Role           | Responsibility              |
| -------------- | --------------------------- |
| Smart Contract | Solidity, deployment, Kwala |
| Frontend       | UI + integration            |
| Product        | UX, pitch, demo             |

---

## 🏁 Summary

> VaultWise makes saving and earning yield as simple as:
> **Save → Invest → Earn**

Powered by:

* Aave
* Kwala workflows
* Fully on-chain architecture

````



