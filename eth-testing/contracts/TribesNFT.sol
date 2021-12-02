//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "./TribesState.sol";
import "./TribesAdmin.sol";
import "./@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./@openzeppelin/contracts/utils/Counters.sol";

contract TribesNFT is ERC721, IHyperverseModule {
    using Counters for Counters.Counter;

    TribesState tribesState;
    TribesAdmin tribesAdmin;

    struct Tenant {
        address whoCanCallMe; 
        address owner;
        Counters.Counter _tokenIds;
    }

    mapping(address => Tenant) tenants;

    constructor(address _tribesState, address _tribesAdmin)
        ERC721("Game Item", "GITM")
    {
        metadata = ModuleMetadata(
            "TribesNFT",
            Author(
                0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
                "https://externallink.net"
            ),
            "0.0.1",
            3479831479814,
            "https://externalLink.net"
        );
        tribesState = TribesState(_tribesState);
        tribesAdmin = TribesAdmin(_tribesAdmin);
    }

    function createInstance() external {
        Tenant storage state = tenants[msg.sender];
        state.owner = msg.sender;
    }

    function getState(address tenant) private view returns (Tenant storage) {
        return tenants[tenant];
    }

    // whoCanCallMe should be the address of the TribesFunctions contracts
    // (or the next contract in the dependency tree)
    function restrictCaller(address whoCanCallMe) external {
        getState(msg.sender).whoCanCallMe = whoCanCallMe;
    }

    modifier canCallMe(address tenant) {
        require(msg.sender == getState(tenant).whoCanCallMe, "You cannot call me!");
        _;
    }

    modifier noWhoCanCallMe(address tenant) {
        require(getState(tenant).whoCanCallMe == address(0), "You have to use the Caller function");
        _;
    }

    function mintCaller(address tenant, address minter, address to) public canCallMe(tenant) {
        require(minter == getState(tenant).owner, "You are not the owner of the Tenant!");
        Tenant storage state = getState(tenant);

        state._tokenIds.increment();
        uint256 newItemId = state._tokenIds.current();
        _mint(to, newItemId);
    }

    function mint(address tenant, address to) public noWhoCanCallMe(tenant) {
        require(msg.sender == getState(tenant).owner, "You are not the owner of the Tenant!");
        Tenant storage state = getState(tenant);

        state._tokenIds.increment();
        uint256 newItemId = state._tokenIds.current();
        _mint(to, newItemId);
    }

    // NOTE: We could probably just skip right to TribesState here. I don't know if that's what we're looking for though.
    // Example:
    /*
        function joinTribeCaller(address tenant, address user, uint256 tribeId) public canCallMe(tenant) {
        require(
            balanceOf(user) >= 1,
            "The caller doesn't have enough NFTs!"
        );
        tribesState.joinTribeCaller(tenant, tribeId, user);
    }
    */

    // Added functionality so we need this one and...
    function joinTribeCaller(address tenant, address user, uint256 tribeId) public canCallMe(tenant) {
        require(
            balanceOf(user) >= 1,
            "The caller doesn't have enough NFTs!"
        );
        tribesAdmin.joinTribeCaller(tenant, tribeId, user);
    }

    // this one.
    function joinTribe(address tenant, uint256 tribeId) public noWhoCanCallMe(tenant) {
        require(
            balanceOf(msg.sender) >= 1,
            "The caller doesn't have enough NFTs!"
        );
        tribesAdmin.joinTribeCaller(tenant, tribeId, msg.sender);
    }
}
