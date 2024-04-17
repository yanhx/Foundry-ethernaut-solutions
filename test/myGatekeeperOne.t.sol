// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/GatekeeperOne/GatekeeperOneFactory.sol";
import "../src/Ethernaut.sol";

contract GatekeeperOneTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testMyGatekeeperOneHack() public {
        /**
         *
         * Factory setup *
         *
         */
        GatekeeperOneFactory gatekeeperOneFactory = new GatekeeperOneFactory();
        ethernaut.registerLevel(gatekeeperOneFactory);
        vm.startPrank(tx.origin);
        address levelAddress = ethernaut.createLevelInstance(gatekeeperOneFactory);
        GatekeeperOne ethernautGatekeeperOne = GatekeeperOne(payable(levelAddress));
        vm.stopPrank();
        assertEq(ethernautGatekeeperOne.entrant(), address(0));
        /**
         *
         *    Attack     *
         *
         */

        bytes8 gateKey = bytes8(uint64(uint160(tx.origin))) & 0xFFFFFFFF0000FFFF;
        vm.startPrank(player);
        // for (uint256 i = 0; i <= 8191; i++) {
        //     try ethernautGatekeeperOne.enter{gas: 1000000 + i}(gateKey) returns (bool response) {
        //         if (response) {
        //             console.log(i);
        //         }
        //     } catch {}
        // }
        ethernautGatekeeperOne.enter{gas: 1000000 + 7764}(gateKey);
        // console.log(ethernautGatekeeperOne.entrant());
        // console.log(tx.origin);
        vm.stopPrank();
        vm.startPrank(tx.origin);
        /**
         *
         * Level Submission*
         *
         */
        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(payable(levelAddress));
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
