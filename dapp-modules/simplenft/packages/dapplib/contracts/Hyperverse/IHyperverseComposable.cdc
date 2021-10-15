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

## `ITenantID` resource interface

Defines a publically viewable interface to read the id of a Tenant resource.

## `Tenant` resource

The core resource type that represents an Tenant in the smart contract.

## `instance` function

A function that all clients can call to receive an Tenant resource.

*/

pub contract interface IHyperverseComposable {

    pub var totalTenants: UInt64

    pub resource interface ITenantID {
        pub let id: UInt64
    }

    pub resource Tenant: ITenantID {
        pub let id: UInt64
    }

    pub fun instance(): @Tenant
}
