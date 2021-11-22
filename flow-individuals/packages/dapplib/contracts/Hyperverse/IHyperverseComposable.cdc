import HyperverseModule from "./HyperverseModule.cdc"

pub contract interface IHyperverseComposable {

    pub event TenantCreated(tenant: Address)

    access(contract) var tenants: @{Address: Tenant}
    access(contract) fun getTenant(tenant: Address): &Tenant
    pub fun tenantExists(tenant: Address): Bool

    pub resource interface ITenant {
        pub var holder: Address
    }

    pub resource Tenant: ITenant {
        pub var holder: Address
    }

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource Package {}
}
