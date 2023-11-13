// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import {Test, console2} from "forge-std/Test.sol";
import {ERC20Permit} from "../src/ERC20Permit.sol";
import {GasLessTokenTransfer} from "../src/GasLessTokenTransfer.sol";

contract GassLessToken is Test {
    ERC20Permit public token;
    GasLessTokenTransfer public gassTransfer;
    address public sender;
    address public receiver;
    uint256 constant SENDER_PRIVATE_KEY = 1303;
    uint AMOUNT = 1000;
    uint FEE = 10;

    function setUp() external {
        sender = vm.addr(SENDER_PRIVATE_KEY);
        receiver = address(3);
        token = new ERC20Permit("RONNIE", "RKS", 18);
        token.mint(sender, AMOUNT + FEE);
        gassTransfer = new GasLessTokenTransfer();
    }

    function testGasLessSend() external {
        uint256 _deadline = block.timestamp + 60;

        bytes32 messageHash = getPermit(
            sender,
            address(gassTransfer),
            AMOUNT + FEE,
            _deadline,
            token.nonces(sender)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(
            SENDER_PRIVATE_KEY,
            messageHash
        );
        gassTransfer.send(
            address(token),
            sender,
            receiver,
            AMOUNT,
            FEE,
            _deadline,
            v,
            r,
            s
        );
        assertEq(token.balanceOf(sender), 0, "Sender Token Balance");
        assertEq(token.balanceOf(receiver), AMOUNT, "Receiver Token Balance");
        assertEq(token.balanceOf(address(this)), FEE, "Receiver Token Balance");
    }

    function getPermit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint nonce
    ) internal view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    token.DOMAIN_SEPARATOR(),
                    keccak256(
                        abi.encode(
                            keccak256(
                                "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                            ),
                            owner,
                            spender,
                            value,
                            nonce,
                            deadline
                        )
                    )
                )
            );
    }
}
