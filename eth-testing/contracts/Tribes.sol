//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "../hyperverse/IHyperverseModule.sol";


contract Tribes is IHyperverseModule {
    mapping(address => bool) admins;
    mapping(bytes => TribeData) tribes;
    mapping(address => bool) participants;

    struct TribeData {
        bytes name;
        bytes ipfsHash;
        bytes description;
        mapping(address => bool) members;
        uint256 numOfMembers;
    }


    // address private _factoryContract;

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

    // Don't really need this because all of these calls
    // WILL be from the factory. No one else can get them.
    // modifier isFactory() {
    //     require(
    //         msg.sender == _factoryContract,
    //         "The msgsender must be the factory contract"
    //     );
    //     _;
    // }

    function init(address initialAdmin) external {
        // _factoryContract = msg.sender;
        admins[initialAdmin] = true;

        console.log("init Admin: ", initialAdmin, " ", admins[initialAdmin]);
    }

    modifier isAdmin(address admin) {
        require(admins[admin], "The caller of this function is not an admin.");
        _;
    }

    /* Admin Stuff */

    function addNewAdmin(address admin, address newAdmin)
        public
        isAdmin(admin)
    {
        admins[newAdmin] = true;
    }

    function addNewTribe( 
        address admin,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description) public isAdmin(admin){
        TribeData storage newTribe = tribes[tribeName];
        newTribe.name = tribeName;
        newTribe.description = description;
        newTribe.ipfsHash = ipfsHash;

    }

    /* Public Stuff */

    function getTribeData(bytes memory tribeName)
        public
        view
        returns (
            bytes memory,
            bytes memory,
            bytes memory
        ){
        TribeData storage tribeData = tribes[tribeName];
        return (tribeName, tribeData.ipfsHash, tribeData.description);
    }

    function addMemberToTribe(bytes memory tribeName, address member) public {
        require(!participants[member], "This member is already in a Tribe!");
        participants[member] = true;

        TribeData storage tribeData = tribes[tribeName];
        tribeData.members[member] = true;
        tribeData.numOfMembers += 1;

    }

    function removeMemberFromTribe(bytes memory tribeName, address member)
        public
    {
        require(participants[member], "This member is not in a Tribe!");
        require(
            tribes[tribeName].members[member],
            "This member does not belong to this Tribe!"
        );

        participants[member] = false;

        TribeData storage tribeData = tribes[tribeName];
        tribeData.members[member] = false;
        tribeData.numOfMembers -= 1;

    }
}
