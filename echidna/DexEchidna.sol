// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "../src/Dex/DexFactory.sol";
import "../src/Ethernaut.sol";
import "../src/Dex/Dex.sol";

contract DexEchidna {
    Ethernaut ethernaut;
    DexFactory factory;
    Dex dex;
    address token1Address;
    address token2Address;

    constructor() {
        ethernaut = new Ethernaut();
        factory = new DexFactory();
        ethernaut.registerLevel(factory);
        address levelAddress = ethernaut.createLevelInstance(factory);
        dex = Dex(payable(levelAddress));

        token1Address = dex.token1();
        token2Address = dex.token2();
        ERC20(token1Address).approve(address(dex), type(uint256).max);
        ERC20(token2Address).approve(address(dex), type(uint256).max);
    }

    function add_liquidity(bool token1) public {
        if (token1) {
            uint256 amount = ERC20(token1Address).balanceOf(address(this));
            dex.add_liquidity(token1Address, amount);
        } else {
            uint256 amount = ERC20(token2Address).balanceOf(address(this));
            dex.add_liquidity(token2Address, amount);
        }
    }

    function swap(bool a2b) public {
        uint256 amount;
        if (a2b) {
            amount = ERC20(token1Address).balanceOf(address(this));
            dex.swap(token1Address, token2Address, amount);
        } else {
            amount = ERC20(token2Address).balanceOf(address(this));
            dex.swap(token2Address, token1Address, amount);
        }
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a <= b ? a : b;
    }

    function testSolved() public {
        assert(ERC20(token1Address).balanceOf(address(dex)) > 50);
        assert(ERC20(token2Address).balanceOf(address(dex)) > 50);
    }
}
