// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";

contract HelperConfig is Script {

    struct NetworkConfig {
        address usdc;
        address aavePool;
    }

    NetworkConfig public activeConfig;

    // Polygon Amoy Testnet — ChainID 80002
    address constant AMOY_USDC      = 0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582;
    address constant AMOY_AAVE_POOL = 0x6Ae43d3271ff6888e7Fc43Fd7321a503ff738951;

    // Polygon Mainnet — ChainID 137
    address constant POLYGON_USDC      = 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359;
    address constant POLYGON_AAVE_POOL = 0x794a61358D6845594F94dc1DB02A252b5b4814aD;

    constructor() {
        if (block.chainid == 80002) {
            activeConfig = NetworkConfig({
                usdc:     AMOY_USDC,
                aavePool: AMOY_AAVE_POOL
            });
        } else if (block.chainid == 137) {
            activeConfig = NetworkConfig({
                usdc:     POLYGON_USDC,
                aavePool: POLYGON_AAVE_POOL
            });
        } else {
            // Local Anvil — deploy mocks
            activeConfig = _getOrCreateAnvilConfig();
        }
    }

    function _getOrCreateAnvilConfig() internal returns (NetworkConfig memory) {
        // Deploy mock contracts for local testing
        vm.startBroadcast();
        MockERC20   mockUsdc = new MockERC20("USD Coin", "USDC", 6);
        MockAavePool mockPool = new MockAavePool();
        vm.stopBroadcast();

        return NetworkConfig({
            usdc:     address(mockUsdc),
            aavePool: address(mockPool)
        });
    }
}

// ── Minimal mocks for local Anvil only ──────────────────────

contract MockERC20 {
    string public name;
    string public symbol;
    uint8  public decimals;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name; symbol = _symbol; decimals = _decimals;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        balanceOf[from]  -= amount;
        balanceOf[to]    += amount;
        allowance[from][msg.sender] -= amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to]         += amount;
        return true;
    }
}

contract MockAavePool {
    function supply(address, uint256, address, uint16) external {}
    function withdraw(address, uint256, address) external returns (uint256) { return 0; }
}