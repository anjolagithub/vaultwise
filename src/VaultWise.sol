// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IAavePool {
    function supply(address asset, uint256 amount, address onBehalfOf, uint16 referralCode) external;
    function withdraw(address asset, uint256 amount, address to) external returns (uint256);
}

/// @title VaultWise
/// @notice On-chain savings vault with Aave V3 yield, automated by Kwala
contract VaultWise is ReentrancyGuard {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                                TYPES
    //////////////////////////////////////////////////////////////*/

    struct Vault {
        address owner;
        uint256 goalAmount;
        uint256 balance;
        uint256 createdAt;
        uint256 duration;
        bool    invested;
        bool    exists;
    }

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    IERC20    public immutable i_usdc;
    IAavePool public immutable i_aavePool;

    uint256 public s_nextVaultId;

    mapping(uint256 => Vault)     public s_vaults;
    mapping(address => uint256[]) public s_userVaults;

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    event VaultCreated(address indexed owner, uint256 indexed vaultId, uint256 goalAmount, uint256 duration);
    event Deposited(address indexed owner, uint256 indexed vaultId, uint256 amount, uint256 newBalance);
    event Invested(address indexed owner, uint256 indexed vaultId, uint256 amount);
    event WithdrawRequested(address indexed owner, uint256 indexed vaultId, uint256 amount);
    event Withdrawn(address indexed owner, uint256 indexed vaultId, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                ERRORS
    //////////////////////////////////////////////////////////////*/

    error VaultWise__NotVaultOwner();
    error VaultWise__VaultNotFound();
    error VaultWise__ZeroAmount();
    error VaultWise__InsufficientBalance();
    error VaultWise__AlreadyInvested();
    error VaultWise__InvalidDuration();

    /*//////////////////////////////////////////////////////////////
                               MODIFIERS
    //////////////////////////////////////////////////////////////*/

    modifier onlyVaultOwner(uint256 vaultId) {
        if (!s_vaults[vaultId].exists)               revert VaultWise__VaultNotFound();
        if (s_vaults[vaultId].owner != msg.sender)   revert VaultWise__NotVaultOwner();
        _;
    }

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address _usdc, address _aavePool) {
        i_usdc     = IERC20(_usdc);
        i_aavePool = IAavePool(_aavePool);
    }

    /*//////////////////////////////////////////////////////////////
                           CORE FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function createVault(uint256 goalAmount, uint256 duration)
        external
        returns (uint256 vaultId)
    {
        if (goalAmount == 0) revert VaultWise__ZeroAmount();
        if (duration == 0)   revert VaultWise__InvalidDuration();

        vaultId = s_nextVaultId++;

        s_vaults[vaultId] = Vault({
            owner:      msg.sender,
            goalAmount: goalAmount,
            balance:    0,
            createdAt:  block.timestamp,
            duration:   duration,
            invested:   false,
            exists:     true
        });

        s_userVaults[msg.sender].push(vaultId);
        emit VaultCreated(msg.sender, vaultId, goalAmount, duration);
    }

    function deposit(uint256 vaultId, uint256 amount)
        external
        onlyVaultOwner(vaultId)
        nonReentrant
    {
        if (amount == 0) revert VaultWise__ZeroAmount();

        s_vaults[vaultId].balance += amount;
        i_usdc.safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(msg.sender, vaultId, amount, s_vaults[vaultId].balance);
    }

    /// @notice Invest vault funds into Aave V3.
    ///         Contract executes Aave supply directly.
    ///         Kwala listens to Invested event and sends Telegram notification.
   function invest(uint256 vaultId)
    external
    onlyVaultOwner(vaultId)
    nonReentrant
{
    Vault storage vault = s_vaults[vaultId];
    if (vault.invested)     revert VaultWise__AlreadyInvested();
    if (vault.balance == 0) revert VaultWise__ZeroAmount();

        uint256 amount = vault.balance;
        vault.balance  = 0;
        vault.invested = true;

        i_usdc.approve(address(i_aavePool), amount);
        i_aavePool.supply(address(i_usdc), amount, vault.owner, 0);

        emit Invested(msg.sender, vaultId, amount);
    }

    /// @notice Withdraw from vault.
    ///         If not invested: returns USDC directly from contract.
    ///         If invested: emits event — Kwala handles Aave withdrawal.
    function withdraw(uint256 vaultId, uint256 amount)
        external
        onlyVaultOwner(vaultId)
        nonReentrant
    {
        Vault storage vault = s_vaults[vaultId];
        if (amount == 0) revert VaultWise__ZeroAmount();

        if (!vault.invested) {
            if (vault.balance < amount) revert VaultWise__InsufficientBalance();
            vault.balance -= amount;
            i_usdc.safeTransfer(msg.sender, amount);
            emit Withdrawn(msg.sender, vaultId, amount);
            return;
        }

        // Funds are in Aave — Kwala handles the withdrawal
        emit WithdrawRequested(msg.sender, vaultId, amount);
    }

    /*//////////////////////////////////////////////////////////////
                               GETTERS
    //////////////////////////////////////////////////////////////*/

    function getVault(uint256 vaultId) external view returns (Vault memory) {
        if (!s_vaults[vaultId].exists) revert VaultWise__VaultNotFound();
        return s_vaults[vaultId];
    }

    function getUserVaults(address user) external view returns (uint256[] memory) {
        return s_userVaults[user];
    }

    function getUsdc() external view returns (address) { return address(i_usdc); }
    function getAavePool() external view returns (address) { return address(i_aavePool); }
}