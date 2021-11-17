import HyperverseModule from "./HyperverseModule.cdc"
import HyperverseAuth from "./HyperverseAuth.cdc"

pub contract interface IHyperverseComposable {

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata

    pub event TenantCreated(id: String)
    access(contract) var clientTenants: {Address: String}
    pub fun getClientTenantID(account: Address): String?
    access(contract) var tenants: @{String: Tenant}
    pub fun getTenant(id: String): &{ITenant}

    access(contract) var aliases: {String: String}
    pub fun addAlias(auth: &HyperverseAuth.Auth, new: String)

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
