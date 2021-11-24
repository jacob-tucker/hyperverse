//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../hyperverse/IHyperverseModule.sol";

contract TribesNew is IHyperverseModule {
    struct Tenant {
        mapping(address => bool) admins;
        mapping(bytes => TribeData) tribes;
        mapping(address => bool) participants;
        address owner;
    }

    struct TribeData {
        bytes name;
        bytes ipfsHash;
        bytes description;
        mapping(address => bool) members;
        uint256 numOfMembers;
    }

    mapping(address => Tenant) tenants;

    event JoinedTribe(bytes tribeName, address newMember);

    event NewTribeCreated(bytes name, bytes ipfsHash, bytes description);

    constructor()
        IHyperverseModule(
            "Tribes",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net",
            new bytes[](0)
        )
    {}

    function createTribes() external {
        Tenant storage state = tenants[msg.sender];

        console.log("Tribes instance for ", msg.sender, " created");

        state.admins[msg.sender] = true;
        state.owner = msg.sender;
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
            getProxy(tenant).admins[msg.sender],
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

    function getProxy(address tenant) private view returns (Tenant storage) {
        return tenants[tenant];
    }

    function addNewTribe(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description
    ) public isAdmin(tenant) {
        emit NewTribeCreated(tribeName, ipfsHash, description);

        TribeData storage newTribe = getProxy(tenant).tribes[tribeName];
        newTribe.name = tribeName;
        newTribe.description = description;
        newTribe.ipfsHash = ipfsHash;
    }

    function joinTribe(
        address tenant,
        bytes memory tribeName,
        address member
    ) public {
        emit JoinedTribe(tribeName, member);

        Tenant storage state = getProxy(tenant);
        require(
            !state.participants[member],
            "This member is already in a Tribe!"
        );
        state.participants[member] = true;

        TribeData storage tribeData = state.tribes[tribeName];
        tribeData.members[member] = true;
        tribeData.numOfMembers += 1;
    }

    function getTribeData(address tenant, bytes memory tribeName)
        public
        view
        returns (
            bytes memory,
            bytes memory,
            bytes memory
        )
    {
        Tenant storage state = getProxy(tenant);
        TribeData storage tribeData = state.tribes[tribeName];
        return (tribeData.name, tribeData.ipfsHash, tribeData.description);
    }
}
