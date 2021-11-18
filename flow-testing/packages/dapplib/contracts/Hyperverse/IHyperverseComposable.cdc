import HyperverseModule from "./HyperverseModule.cdc"

pub contract interface IHyperverseComposable {

    pub event TenantCreated(id: String)

    pub fun clientTenantID(account: Address): String
    access(contract) var tenants: @{String: Tenant}
    pub fun tenantExists(account: Address): Bool

    pub resource interface ITenant {
        pub var holder: Address
    }

    pub resource Tenant: ITenant {
        pub var holder: Address
    }

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource Package {
       
    }
}
