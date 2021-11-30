//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../hyperverse/IHyperverseModule.sol";

contract Greeter is IHyperverseModule {
    struct Tenant {
        string greeting;
        address owner;
    }

    mapping(address => Tenant) public tenants;

    constructor()
    {}

    modifier isOwner(address tenant) {
        require(
            getState(tenant).owner == msg.sender, 
            "You must be the owner of the Tenant to make this call"
        );
        _;
    }

    function createInstance(string memory _greeting) external {
        Tenant storage state = tenants[msg.sender];
        state.greeting = _greeting;
        state.owner = msg.sender;
    }

    function getState(address tenant) private view returns (Tenant storage) {
        return tenants[tenant];
    }

    function greet(address tenant) public view returns (string memory) {
        return getState(tenant).greeting;
    }

    function setGreeting(address tenant, string memory _greeting) public isOwner(tenant) {
        Tenant storage state = getState(tenant);
        state.greeting = _greeting;
    }
}
