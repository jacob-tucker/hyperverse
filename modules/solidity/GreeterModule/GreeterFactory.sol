//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../CloneFactory.sol";
import "./Greeter.sol";

contract GreeterFactory is CloneFactory {
    struct Tenant {
        Greeter greeter;
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

    function createGreeter(address tenant, string memory _greeter) external {
        Greeter greeter = Greeter(createClone(masterContract));
        greeter.init(_greeter);

        Tenant storage newTenant = tenants[tenant];
        newTenant.greeter = greeter;
        newTenant.admins[tenant] = true;
        newTenant.owner = tenant;
    }

    function getMaster() external view returns (address) {
        return masterContract;
    }

    function getProxy(address tenant) private view returns (Greeter) {
        return tenants[tenant].greeter;
    }

    function greeting(address tenant) public view returns (string) {
        return getProxy(tenant).greet();
    }
}
