//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import './CloneFactory.sol';
import './MorganToken.sol';

// A factory contract that produced MorganTokens without copying their logic
// This contract creates "Proxy" contracts on line __. Those Proxy contracts
// belong to a Tenant. 
//
// What happens is the Proxy gets stored under a Tenant -> if a Tenant wants
// to do something with it, they execute something on that Proxy -> the Proxy
// `delegatecall`s the Master Contract which uses the master contract's logic
// but the Proxy's state.
contract MorganTokenFactory is CloneFactory {
    struct Tenant {
        MorganToken morganToken;
        mapping(address => bool) admins;
        address owner;
    }

    mapping(address => Tenant) public tenants;
     
    // The address of the MorganToken contract
    address masterContract;

    constructor(address _masterContract){
        masterContract = _masterContract;
    }

    // Checks to see if the caller is an owner of a tenant
    modifier isOwner(address tenant) {
        require(tenants[tenant].owner == msg.sender, "The calling address is not an owner of a tenant");
        _;
    }

    // Checks to see if the caller is an admin for the specified tenant
    modifier isAdmin(address tenant) {
        require(tenants[tenant].admins[msg.sender], "The calling address is not an admin");
        _;
    }

    function addAdmin(address tenant, address newAdmin) external isOwner(tenant) {
        tenants[tenant].admins[newAdmin] = true;
    }

    function removeAdmin(address tenant, address newAdmin) external isOwner(tenant) {
        tenants[tenant].admins[newAdmin] = false;
    }

    function createMorganToken(address tenant) external{
        // The system looks like this:
        // Alice --[calls]--> MorganTokenFactory --[calls]--> Proxy Contract (cloned here and stored in `tenants`) --[delegate calls]--> MorganToken
        // You can see that the `msg.sender` inside MorganToken will be the MorganTokenFactory
        // We can use this to give permission to this contract.
        MorganToken morganToken = MorganToken(createClone(masterContract));

        // Won't do anything since the initial state isn't much
        // But if wanted to set initial state for our MorganToken,
        // we would do that here.
        //
        // Note: this sets this factory contract as the _factoryContract
        // in the master contract
        morganToken.init();

        Tenant storage newTenant = tenants[tenant];
        newTenant.morganToken = morganToken;
        newTenant.admins[tenant] = true;
        newTenant.owner = tenant;
    }

    function getMaster() external view returns (address) {
        return masterContract;
    }

    function getProxy(address tenant) private view returns (MorganToken) {
        return tenants[tenant].morganToken;
    }
     
    function mint(address tenant, address account, uint256 amount) public isAdmin(tenant) {
        getProxy(tenant).mint(account, amount);
    }
    
    function balanceOf(address tenant, address account) public view returns (uint256) {
        return getProxy(tenant).balanceOf(account);
    }
    
    function getFactory(address tenant) external view returns (address) {
        return getProxy(tenant).getFactory();
    }
}
