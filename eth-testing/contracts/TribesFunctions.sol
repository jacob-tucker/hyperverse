//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "./TribesState.sol";
import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";

contract TribesFunctions is ERC721, IHyperverseModule {
    using Counters for Counters.Counter;

    TribesState tribesState;
    struct Tenant {
        mapping(address => bool) admins;
        address owner;
        Counters.Counter _tokenIds;
    }

    mapping(address => Tenant) tenants;

    constructor(address _tribesState) ERC721("Game Item", "GITM") {
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

    function mint(address tenant, address to) public {
        Tenant storage state = getState(tenant);
        require(
            msg.sender == state.owner,
            "Only the owner of this contract can mint."
        );

        state._tokenIds.increment();
        uint256 newItemId = state._tokenIds.current();
        _mint(to, newItemId);
    }

    function addNewTribe(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description
    ) external isAdmin(tenant) {
        tribesState.addNewTribe(tenant, tribeName, ipfsHash, description);
    }

    function joinTribe(address tenant, uint256 tribeId) public {
        require(
            balanceOf(msg.sender) >= 1,
            "The caller doesn't have enough NFTs!"
        );
        tribesState.joinTribeCaller(tenant, tribeId, msg.sender);
    }
}
