/**

## The Decentology Smart Contract Composability standard on Flow

## `IHyperverseComposable` contract interface

The interface that all multitenant/composable smart contracts should conform to.
If a user wants to deploy a new composable contract, their contract would need
to implement this contract interface.

Their contract would have to follow all the rules and naming
that the interface specifies.

## `totalTenants` UInt64

The number of Tenants that have been created.

## `clientTenants` dictionary

A dictionary that maps the Address of a client to the amount of Tenants it has
created through calling `instance`.

## `ITenant` resource interface

Defines a publically viewable interface to read the id of a Tenant resource

## `Tenant` resource

The core resource type that represents an Tenant in the smart contract.

## `instance` function

A function that all clients can call to receive an Tenant resource. The client
passes in their Address so clientTenants can get updated.

## `getTenants` function

A function that returns clientTenants

*/

import HyperverseService from "./HyperverseService.cdc"
import TenantCollection from "./TenantCollection.cdc"

pub contract interface IHyperverseComposable {

    // Maps an address (of the customer/DappContract) to the amount
    // of tenants they have for a specific HyperverseContract.
    access(contract) var clientTenants: {Address: UInt64}

    // instance
    // instance returns an Tenant resource.
    //
    pub fun instance(authNFT: Capability<&HyperverseService.AuthNFT>, tenantCollection: Capability<&TenantCollection.Collection>): UInt64 {
        pre {
            authNFT.borrow() != nil:
                "This is not a functioning AuthNFT Capability."
        }
    }

    // getTenants
    // getTenants returns clientTenants.
    //
    pub fun getTenants(): {Address: UInt64}
}
