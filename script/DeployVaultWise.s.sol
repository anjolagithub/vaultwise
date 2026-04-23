// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {VaultWise}   from "../src/VaultWise.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployVaultWise is Script {

    function run() external returns (VaultWise, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();
        (address usdc, address aavePool) = helperConfig.activeConfig();

        vm.startBroadcast();
        VaultWise vaultWise = new VaultWise(usdc, aavePool);
        vm.stopBroadcast();

        console.log("VaultWise deployed at:", address(vaultWise));
        console.log("USDC address:         ", usdc);
        console.log("Aave Pool address:    ", aavePool);
        console.log("Chain ID:             ", block.chainid);

        return (vaultWise, helperConfig);
    }
}