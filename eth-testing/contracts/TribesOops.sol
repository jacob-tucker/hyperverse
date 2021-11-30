//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract TribesOops is IHyperverseModule {
    using Counters for Counters.Counter;

    struct Tenant {
        mapping(address => bool) admins;
        mapping(uint256 => TribeData) tribes;
        mapping(address => uint256) participants;
        //add an array of names? so we can join tribe by finding index on array?
        address owner;
        Counters.Counter tribeIds;
    }

    struct TribeData {
        bytes name;
        bytes ipfsHash;
        bytes description;
        mapping(address => bool) members;
        uint256 numOfMembers;
        uint256 tribeId;
    }

    mapping(address => Tenant) tenants;

    event JoinedTribe(uint256 tribeId, address newMember);
    event LeftTribe(uint256 tribeId, address member);
    event NewTribeCreated(bytes name, bytes ipfsHash, bytes description);

    constructor()
    {
        metadata = ModuleMetadata(
            "Tribes",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net"
        );
    }

    function createInstance() external {
        Tenant storage state = tenants[msg.sender];
        state.admins[msg.sender] = true;
        state.owner = msg.sender;
    }

    // Checks to see if the caller is an owner of a tenant
    modifier isOwner(address tenant) {
        require(
            getState(tenant).owner == msg.sender,
            "The calling address is not an owner of a tenant"
        );
        _;
    }

    // Checks to see if the caller is an admin for the specified tenant
    modifier isAdmin(address tenant) {
        require(
            getState(tenant).admins[msg.sender],
            "The calling address is not an admin"
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

    function getState(address tenant) private view returns (Tenant storage) {
        return tenants[tenant];
    }

    function addNewTribe(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description
    ) external isAdmin(tenant) {
        emit NewTribeCreated(tribeName, ipfsHash, description);

        Tenant storage state = getState(tenant);

        state.tribeIds.increment();

        uint256 newTribeId = state.tribeIds.current();

        TribeData storage newTribe = state.tribes[newTribeId];
        newTribe.name = tribeName;
        newTribe.description = description;
        newTribe.ipfsHash = ipfsHash;
        newTribe.tribeId = newTribeId;
    }

    function _beforeJoinTribe() internal virtual {}

    function joinTribe(address tenant, uint256 tribeId) public {
        address member = msg.sender;
        Tenant storage state = getState(tenant);
        require(
            state.participants[member] == 0,
            "This member is already in a Tribe!"
        );
        require(state.tribeIds.current() >= tribeId, "Tribe does not exist");

        _beforeJoinTribe();

        state.participants[member] = tribeId;
        TribeData storage tribeData = state.tribes[tribeId];
        tribeData.members[member] = true;
        tribeData.numOfMembers += 1;

        emit JoinedTribe(tribeId, member);
    }

    function leaveTribe(address tenant) public {
        address member = msg.sender;
        Tenant storage state = getState(tenant);
        //extra layer - not sure if necessary
        require(
            state.participants[member] != 0,
            "This member is not in a Tribe!"
        );
        emit LeftTribe(state.participants[member], member);
        TribeData storage tribeData = state.tribes[state.participants[member]];
        state.participants[member] = 0;
        tribeData.members[member] = false;
        tribeData.numOfMembers -= 1;
    }

    function getUserTribe(address tenant) public view returns (bytes memory) {
        address member = msg.sender;
        Tenant storage state = getState(tenant);

        require(
            state.participants[member] != 0,
            "This member is not in a Tribe!"
        );

        uint256 tribeId = state.participants[member];
        TribeData storage tribeData = state.tribes[tribeId];
        return tribeData.name;
    }

    function getTribeData(address tenant, uint256 tribeId)
        public
        view
        returns (
            bytes memory,
            bytes memory,
            bytes memory
        )
    {
        Tenant storage state = getState(tenant);
        TribeData storage tribeData = state.tribes[tribeId];
        return (tribeData.name, tribeData.ipfsHash, tribeData.description);
    }

    function totalTribes(address tenant) public view returns (uint256) {
        return getState(tenant).tribeIds.current();
    }
}
