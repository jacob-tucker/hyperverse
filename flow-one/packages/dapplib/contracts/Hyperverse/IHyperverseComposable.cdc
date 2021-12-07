import HyperverseModule from "./HyperverseModule.cdc"

pub contract interface IHyperverseComposable {

    pub event TenantCreated(tenant: Address)

    access(contract) var tenants: @{Address: Tenant}
    access(contract) fun getTenant(tenant: Address): &Tenant
    pub fun tenantExists(tenant: Address): Bool

    pub resource interface ITenant {
        pub var tenant: Address
    }

    pub resource Tenant: ITenant {
        pub var tenant: Address
    }
}
