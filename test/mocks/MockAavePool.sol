// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockAavePool {
    event Supplied(address asset, uint256 amount, address onBehalfOf);
    event Withdrawn(address asset, uint256 amount, address to);

    function supply(address asset, uint256 amount, address onBehalfOf, uint16) external {
        emit Supplied(asset, amount, onBehalfOf);
    }

    function withdraw(address asset, uint256 amount, address to) external returns (uint256) {
        emit Withdrawn(asset, amount, to);
        return amount;
    }
}


