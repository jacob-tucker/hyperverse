//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../CloneFactory.sol";
import "./Tribes.sol";

contract TribesFactory is CloneFactory {
    struct Tenant {
        Tribes tribesInstance;
        mapping(address => bool) admins;
        address owner;
    }

    mapping(address => Tenant) public tenants;

    address masterContract;

    constructor(address _masterContract) {
        masterContract = _masterContract;
    }

    // Checks to see if the caller is an owner of a tenant
    modifier isOwner(address tenant) {
        require(
            tenants[tenant].owner == msg.sender,
            "The calling address is not an owner of a tenant"
        );
        _;
    }

    // Checks to see if the caller is an admin for the specified tenant
    modifier isAdmin(address tenant) {
        require(
            tenants[tenant].admins[msg.sender],
            "The calling address is not an admin"
        );
        _;
    }

    function addAdmin(address tenant, address newAdmin)
        external
        isOwner(tenant)
    {
        tenants[tenant].admins[newAdmin] = true;
    }

    function removeAdmin(address tenant, address newAdmin)
        external
        isOwner(tenant)
    {
        tenants[tenant].admins[newAdmin] = false;
    }

    function createTribes(address tenant) external {
        Tribes tribesInstance = Tribes(createClone(masterContract));
        tribesInstance.init(msg.sender);

        Tenant storage newTenant = tenants[tenant];
        newTenant.tribesInstance = tribesInstance;
        newTenant.admins[tenant] = true;
        newTenant.owner = tenant;
    }

    function getMaster() external view returns (address) {
        return masterContract;
    }

    function getProxy(address tenant) private view returns (Tribes) {
        return tenants[tenant].tribesInstance;
    }
}
