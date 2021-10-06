// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0 <0.9.0;

import "../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Must derive from IHyperverseModule to be a Hyperverse Module
contract MorganTokenv2 is ERC20 {
    constructor() ERC20("MorganToken", "MGT") {}

    function transferEvent(
        address from,
        address to,
        uint256 value
    ) internal {
        emit Transfer(from, to, value);
    }

    function approvalEvent(
        address owner,
        address spender,
        uint256 value
    ) internal {
        emit Approval(owner, spender, value);
    }
}
