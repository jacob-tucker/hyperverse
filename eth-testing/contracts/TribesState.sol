//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";

contract TribesState is IHyperverseModule {
    using Counters for Counters.Counter;

    struct Tenant {
        address whoCanCallMe;
        mapping(uint256 => TribeData) tribes;
        mapping(address => uint256) participants;
        Counters.Counter tribeIds;
        address owner;
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

    constructor() {
        metadata = ModuleMetadata(
            "TribesState",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net"
        );
    }

    function getState(address tenant) private view returns (Tenant storage) {
        return tenants[tenant];
    }

    // If there's a msg.sender involved and we want calling contract to decide
    modifier canCallMe(address tenant) {
        require(msg.sender == getState(tenant).whoCanCallMe, "You cannot call me!");
        _;
    }

    // If there's a msg.sender involved and we want a user to call directly
    modifier noWhoCanCallMe(address tenant) {
        require(getState(tenant).whoCanCallMe == address(0), "You have to use the Caller function");
        _;
    }

    // Use this one if there is no msg.sender involved
    // If a function is marked with `either`, that means they
    // do not need to have duplicate functions
    modifier either(address tenant) {
        require(
            getState(tenant).whoCanCallMe == address(0) || msg.sender == getState(tenant).whoCanCallMe, 
            "You have to use the Caller function");
        _;
    }
 
    // whoCanCallMe should be the address of the TribesFunctions contracts
    // (or the next contract in the dependency tree)
    function restrictCaller(address whoCanCallMe) external {
        getState(msg.sender).whoCanCallMe = whoCanCallMe;
    }

    function addNewTribeCaller(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description
    ) external either(tenant) {
        Tenant storage state = getState(tenant);

        state.tribeIds.increment();
        uint256 newTribeId = state.tribeIds.current();

        TribeData storage newTribe = state.tribes[newTribeId];
        newTribe.name = tribeName;
        newTribe.description = description;
        newTribe.ipfsHash = ipfsHash;
        newTribe.tribeId = newTribeId;

        emit NewTribeCreated(tribeName, ipfsHash, description);
    }

    function joinTribeCaller(
        address tenant,
        uint256 tribeId,
        address user
    ) public canCallMe(tenant) {
        Tenant storage state = getState(tenant);
        require(
            state.participants[user] == 0,
            "This member is already in a Tribe!"
        );
        require(state.tribeIds.current() >= tribeId, "Tribe does not exist");

        state.participants[user] = tribeId;
        TribeData storage tribeData = state.tribes[tribeId];
        tribeData.members[user] = true;
        tribeData.numOfMembers += 1;

        emit JoinedTribe(tribeId, user);
    }

    function joinTribe(address tenant, uint256 tribeId) public noWhoCanCallMe(tenant) {
        address user = msg.sender;
        Tenant storage state = getState(tenant);
        require(
            state.participants[user] == 0,
            "This member is already in a Tribe!"
        );
        require(state.tribeIds.current() >= tribeId, "Tribe does not exist");

        state.participants[user] = tribeId;
        TribeData storage tribeData = state.tribes[tribeId];
        tribeData.members[user] = true;
        tribeData.numOfMembers += 1;

        emit JoinedTribe(tribeId, user);
    }

    function leaveTribeCaller(address tenant, address member) public canCallMe(tenant) {
        Tenant storage state = getState(tenant);
        require(
            state.participants[member] != 0,
            "This member is not in a Tribe!"
        );

        TribeData storage tribeData = state.tribes[state.participants[member]];
        state.participants[member] = 0;
        tribeData.members[member] = false;
        tribeData.numOfMembers -= 1;

        emit LeftTribe(state.participants[member], member);
    }

    function leaveTribe(address tenant) public noWhoCanCallMe(tenant) {
        address member = msg.sender;
        Tenant storage state = getState(tenant);
        require(
            state.participants[member] != 0,
            "This member is not in a Tribe!"
        );

        TribeData storage tribeData = state.tribes[state.participants[member]];
        state.participants[member] = 0;
        tribeData.members[member] = false;
        tribeData.numOfMembers -= 1;

        emit LeftTribe(state.participants[member], member);
    }

    function getUserTribe(address tenant, address user)
        public
        view
        returns (uint256)
    {
        Tenant storage state = getState(tenant);

        require(
            state.participants[user] != 0,
            "This member is not in a Tribe!"
        );

        uint256 tribeId = state.participants[user];
        return tribeId;
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
