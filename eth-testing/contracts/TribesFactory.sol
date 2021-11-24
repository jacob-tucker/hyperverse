//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../hyperverse/CloneFactory.sol";
import "./Tribes.sol";

contract TribesFactory is CloneFactory {
    struct Tenant {
        Tribes tribesInstance;
        mapping(address => bool) admins;
        address owner;
    }

    mapping(address => Tenant) public tenants;

    address masterContract;

    event JoinedTribe(
        bytes tribeName,
        address newMember
    );

    event NewTribeCreated(
        bytes name,
        bytes ipfsHash,
        bytes description
    );
    
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

    function createTribes() external {
        Tribes tribesInstance = Tribes(createClone(masterContract));
        tribesInstance.init(msg.sender);

        console.log("Tribes instance for ", msg.sender, " created");
        console.log("Sender  ", msg.sender);
        Tenant storage newTenant = tenants[msg.sender];
        newTenant.tribesInstance = tribesInstance;
        newTenant.admins[msg.sender] = true;
        newTenant.owner = msg.sender;
    }

    function getMaster() external view returns (address) {
        return masterContract;
    }

    function getProxy(address tenant) private view returns (Tribes) {
        return tenants[tenant].tribesInstance;
    }

    function addNewTribe(address tenant, bytes memory tribeName, bytes memory ipfsHash, bytes memory description) public isAdmin(tenant) {
            emit NewTribeCreated(tribeName, ipfsHash, description);
            return getProxy(tenant).addNewTribe(msg.sender, tribeName, ipfsHash, description);
    }
    
    function joinTribe(address tenant, bytes memory tribeName, address member) public  {
        emit JoinedTribe(tribeName, member);
        return getProxy(tenant).addMemberToTribe(tribeName, member);
    }
}
