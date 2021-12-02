//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "../hyperverse/IHyperverseModule.sol";
import "./TribesState.sol";

contract TribesAdmin is IHyperverseModule {
    TribesState tribesState;
    
    struct Tenant {
        address whoCanCallMe;
        mapping(address => bool) admins;
        address owner;
    }

    mapping(address => Tenant) public tenants;

    constructor(address _tribesState) {
        metadata = ModuleMetadata(
            "TribesAdmin",
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

    // whoCanCallMe should be the address of the TribesFunctions contracts
    // (or the next contract in the dependency tree)
    function restrictCaller(address whoCanCallMe) external {
        getState(msg.sender).whoCanCallMe = whoCanCallMe;
    }

    // Checks to see if the caller is an owner of a tenant
    modifier isOwner(address tenant, address owner) {
        require(getState(tenant).owner == owner, "The calling address is the Owner of the Tenant");
        _;
    }

    modifier canCallMe(address tenant) {
        require(msg.sender == getState(tenant).whoCanCallMe, "You cannot call me!");
        _;
    }

    modifier noWhoCanCallMe(address tenant) {
        require(getState(tenant).whoCanCallMe == address(0), "You have to use the Caller function");
        _;
    }

    // Checks to see if the caller is an admin for the specified tenant
    modifier isAdmin(address tenant, address admin) {
        require(getState(tenant).admins[admin],"The calling address is not an Admin");
        _;
    }

    // Should this be isAdmin()?
    function addAdminCaller(address tenant, address owner, address newAdmin)
        external
        isOwner(tenant, owner) canCallMe(tenant)
    {
        getState(tenant).admins[newAdmin] = true;
    }

    function addAdmin(address tenant, address newAdmin)
        external
        isOwner(tenant, msg.sender) noWhoCanCallMe(tenant)
    {
        getState(tenant).admins[newAdmin] = true;
    }

    // Should this be isAdmin()?
    function removeAdminCaller(address tenant, address owner, address newAdmin)
        external
        isOwner(tenant, owner) canCallMe(tenant)
    {
        getState(tenant).admins[newAdmin] = false;
    }

    // Should this be isAdmin()?
    function removeAdmin(address tenant, address newAdmin)
        external
        isOwner(tenant, msg.sender) noWhoCanCallMe(tenant)
    {
        getState(tenant).admins[newAdmin] = false;
    }
 
    function addNewTribeCaller(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description,
        address admin
    ) external isAdmin(tenant, admin) canCallMe(tenant) {
        tribesState.addNewTribeCaller(tenant, tribeName, ipfsHash, description);
    }

    function addNewTribe(
        address tenant,
        bytes memory tribeName,
        bytes memory ipfsHash,
        bytes memory description
    ) external isAdmin(tenant, msg.sender) noWhoCanCallMe(tenant) {
        tribesState.addNewTribeCaller(tenant, tribeName, ipfsHash, description);
    }

    // This is called by a contract building on top of this module
    function joinTribeCaller(
        address tenant,
        uint256 tribeId,
        address user
    ) public canCallMe(tenant) {
        tribesState.joinTribeCaller(tenant, tribeId, user);
    }

    // Don't need a joinTribe() because this function isn't adding any extra functionality
    // so it will only ever be called by an external contract
    // **SO: Any NEW functionality needs both methods. Any "forwarding" calls like this one
    // can just have the one function where there's no added functionality.

    function leaveTribeCaller(address tenant, address member) public canCallMe(tenant) {
        tribesState.leaveTribeCaller(tenant, member);
    }
}
