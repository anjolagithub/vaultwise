// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {DeployVaultWise} from "../../script/DeployVaultWise.s.sol";
import {HelperConfig}    from "../../script/HelperConfig.s.sol";
import {VaultWise}       from "../../src/VaultWise.sol";
import {ERC20Mock}       from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract VaultWiseTest is Test {

    event VaultCreated(address indexed owner, uint256 indexed vaultId, uint256 goalAmount, uint256 duration);
    event Deposited(address indexed owner, uint256 indexed vaultId, uint256 amount, uint256 newBalance);
    event Invested(address indexed owner, uint256 indexed vaultId, uint256 amount);
    event WithdrawRequested(address indexed owner, uint256 indexed vaultId, uint256 amount);

    VaultWise    vaultWise;
    HelperConfig helperConfig;

    address alice = makeAddr("alice");
    address bob   = makeAddr("bob");

    uint256 constant USDC_DECIMALS  = 1e6;
    uint256 constant GOAL           = 1000 * USDC_DECIMALS;
    uint256 constant DURATION       = 30 days;
    uint256 constant DEPOSIT_AMOUNT = 500 * USDC_DECIMALS;

    function setUp() public {
        DeployVaultWise deployer = new DeployVaultWise();
        (vaultWise, helperConfig) = deployer.run();

        address usdc = vaultWise.getUsdc();
        ERC20Mock(usdc).mint(alice, 2000 * USDC_DECIMALS);
    }

    function test_CreateVault_Succeeds() public {
        vm.prank(alice);
        uint256 id = vaultWise.createVault(GOAL, DURATION);
        assertEq(id, 0);

        VaultWise.Vault memory v = vaultWise.getVault(0);
        assertEq(v.owner,      alice);
        assertEq(v.goalAmount, GOAL);
        assertEq(v.balance,    0);
        assertFalse(v.invested);
    }

    function test_CreateVault_EmitsEvent() public {
        vm.prank(alice);
        vm.expectEmit(true, true, false, true);
        emit VaultCreated(alice, 0, GOAL, DURATION);
        vaultWise.createVault(GOAL, DURATION);
    }

    function test_CreateVault_RevertsOnZeroGoal() public {
        vm.prank(alice);
        vm.expectRevert(VaultWise.VaultWise__ZeroAmount.selector);
        vaultWise.createVault(0, DURATION);
    }

    function test_Deposit_UpdatesBalance() public {
        vm.startPrank(alice);
        vaultWise.createVault(GOAL, DURATION);
        ERC20Mock(vaultWise.getUsdc()).approve(address(vaultWise), DEPOSIT_AMOUNT);
        vaultWise.deposit(0, DEPOSIT_AMOUNT);
        vm.stopPrank();

        assertEq(vaultWise.getVault(0).balance, DEPOSIT_AMOUNT);
    }

    function test_Deposit_RevertsIfNotOwner() public {
        vm.prank(alice);
        vaultWise.createVault(GOAL, DURATION);

        vm.prank(bob);
        vm.expectRevert(VaultWise.VaultWise__NotVaultOwner.selector);
        vaultWise.deposit(0, DEPOSIT_AMOUNT);
    }

    function test_Invest_MarksVaultAsInvested() public {
        vm.startPrank(alice);
        vaultWise.createVault(GOAL, DURATION);
        ERC20Mock(vaultWise.getUsdc()).approve(address(vaultWise), DEPOSIT_AMOUNT);
        vaultWise.deposit(0, DEPOSIT_AMOUNT);
        vaultWise.invest(0);
        vm.stopPrank();

        VaultWise.Vault memory v = vaultWise.getVault(0);
        assertTrue(v.invested);
        assertEq(v.balance, 0);
    }

    function test_Invest_EmitsEvent() public {
        vm.startPrank(alice);
        vaultWise.createVault(GOAL, DURATION);
        ERC20Mock(vaultWise.getUsdc()).approve(address(vaultWise), DEPOSIT_AMOUNT);
        vaultWise.deposit(0, DEPOSIT_AMOUNT);

        vm.expectEmit(true, true, false, true);
        emit Invested(alice, 0, DEPOSIT_AMOUNT);
        vaultWise.invest(0);
        vm.stopPrank();
    }

    function test_Invest_RevertsIfAlreadyInvested() public {
        vm.startPrank(alice);
        vaultWise.createVault(GOAL, DURATION);
        ERC20Mock(vaultWise.getUsdc()).approve(address(vaultWise), DEPOSIT_AMOUNT);
        vaultWise.deposit(0, DEPOSIT_AMOUNT);
        vaultWise.invest(0);
        vm.expectRevert(VaultWise.VaultWise__AlreadyInvested.selector);
        vaultWise.invest(0);
        vm.stopPrank();
    }

    function test_Withdraw_BeforeInvest_TransfersFunds() public {
        vm.startPrank(alice);
        vaultWise.createVault(GOAL, DURATION);
        ERC20Mock(vaultWise.getUsdc()).approve(address(vaultWise), DEPOSIT_AMOUNT);
        vaultWise.deposit(0, DEPOSIT_AMOUNT);
        vaultWise.withdraw(0, 200 * USDC_DECIMALS);
        vm.stopPrank();

        assertEq(ERC20Mock(vaultWise.getUsdc()).balanceOf(alice), 1700 * USDC_DECIMALS);
    }

    function test_Withdraw_AfterInvest_EmitsWithdrawRequested() public {
        vm.startPrank(alice);
        vaultWise.createVault(GOAL, DURATION);
        ERC20Mock(vaultWise.getUsdc()).approve(address(vaultWise), DEPOSIT_AMOUNT);
        vaultWise.deposit(0, DEPOSIT_AMOUNT);
        vaultWise.invest(0);

        vm.expectEmit(true, true, false, true);
        emit WithdrawRequested(alice, 0, DEPOSIT_AMOUNT);
        vaultWise.withdraw(0, DEPOSIT_AMOUNT);
        vm.stopPrank();
    }
}
