//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "./TribesState.sol";

contract TribesFunctions is IHyperverseModule {
    TribesState tribesState;
    struct Tenant {
        mapping(address => bool) admins;
        address owner;
    }

    mapping(address => Tenant) public tenants;

    constructor(address _tribesState) {
        metadata = ModuleMetadata(
            "TribesFunctions",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net"
        );

        tribesState = TribesState(_tribesState);
    }

    function createInstance() external {
        Tenant storage state = tenants[msg.sender];
        state.admins[msg.sender] = true;
        state.owner = msg.sender;
    }

    function getState(address tenant) private view returns (Tenant storage) {
        return tenants[tenant];
    }

    // Checks to see if the caller is an owner of a tenant
    modifier isOwner(address tenant) {
        require(
            getState(tenant).owner == msg.sender,
            "The calling address is the Owner of the Tenant"
        );
        _;
    }

    // Checks to see if the caller is an admin for the specified tenant
    modifier isAdmin(address tenant) {
        require(
            getState(tenant).admins[msg.sender],
            "The calling address is not an Admin"
        );
        _;
    }

    // Should this be isAdmin()?
    function addAdmin(address tenant, address newAdmin)
        external
        isOwner(tenant)
    {
        getState(tenant).admins[newAdmin] = true;
    }

    // Should this be isAdmin()?
    function removeAdmin(address tenant, address newAdmin)
        external
        isOwner(tenant)
    {
        getState(tenant).admins[newAdmin] = false;
    }

    function addNewTribe(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description
    ) external isAdmin(tenant) {
        tribesState.addNewTribe(tenant, tribeName, ipfsHash, description);
    }
}
