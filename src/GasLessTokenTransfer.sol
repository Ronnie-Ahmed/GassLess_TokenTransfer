// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.21;
import {IERC20Permit} from "./IERC20Permit.sol";

contract GasLessTokenTransfer {
    function send(
        address token,
        address sender,
        address receiver,
        uint amount,
        uint fee,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20Permit(token).permit(
            sender,
            address(this),
            amount + fee,
            deadline,
            v,
            r,
            s
        );
        IERC20Permit(token).transferFrom(sender, receiver, amount);
        IERC20Permit(token).transferFrom(sender, msg.sender, fee);
    }
}
