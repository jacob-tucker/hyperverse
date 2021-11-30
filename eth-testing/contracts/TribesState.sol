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
        //add an array of names? so we can join tribe by finding index on array?
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

    modifier canCallMe(address tenant) {
        require(
            getState(tenant).whoCanCallMe == address(0) ||
                msg.sender == getState(tenant).whoCanCallMe,
            "You cannot call me!"
        );
        _;
    }

    // whoCanCallMe should be the address of the TribesFunctions contracts
    // (or the next contract in the dependency tree)
    function restrictCaller(address whoCanCallMe) external {
        getState(msg.sender).whoCanCallMe = whoCanCallMe;
    }

    function addNewTribe(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description
    ) external canCallMe(tenant) {
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

    // This is called by a contract building on top of this module
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

    // This is called directly by a user assuming there is no
    // functionality build on top
    function joinTribe(address tenant, uint256 tribeId) public {
        joinTribeCaller(tenant, tribeId, msg.sender);
    }

    function leaveTribe(address tenant) public canCallMe(tenant) {
        address member = msg.sender;
        Tenant storage state = getState(tenant);
        //extra layer - not sure if necessary
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
        returns (bytes memory)
    {
        Tenant storage state = getState(tenant);

        require(
            state.participants[user] != 0,
            "This member is not in a Tribe!"
        );

        uint256 tribeId = state.participants[user];
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
