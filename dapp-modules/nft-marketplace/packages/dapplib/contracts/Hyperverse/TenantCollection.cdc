import HyperverseService from "./HyperverseService.cdc"
import ITenant from "./ITenant.cdc"

pub contract TenantCollection {

    pub var totalTenants: UInt64

    pub let TenantCollectionStoragePath: StoragePath
    pub let TenantCollectionPublicPath: PublicPath

    pub resource interface CollectionPublic {
        pub fun deposit(tenant: @ITenant.Tenant)

        pub fun getTenantIDs(): [UInt64]
    }

    pub resource Collection: CollectionPublic {
        // dictionary of Tenant conforming tenants
        pub var ownedTenants: @{UInt64: ITenant.Tenant}

        // deposit takes a Tenant and adds it to the ownedTenants dictionary
        // and adds the tenantID to the key
        pub fun deposit(tenant: @ITenant.Tenant) {

            let id: UInt64 = tenant.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedTenants[id] <- tenant

            destroy oldToken

            TenantCollection.totalTenants = TenantCollection.totalTenants + (1 as UInt64)
        }

        // getTenantIDs returns an array of the tenantIDs that are in the collection
        pub fun getTenantIDs(): [UInt64] {
            return self.ownedTenants.keys
        }

        // borrowTenant gets a reference to a tenant in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowTenant(tenantID: UInt64): auth &ITenant.Tenant {
            return &self.ownedTenants[tenantID] as auth &ITenant.Tenant
        }

        destroy() {
            destroy self.ownedTenants
        }

        init () {
            self.ownedTenants <- {}
        }
    }

    // public function that anyone can call to create a new empty collection
    pub fun createEmptyCollection(): @Collection {
        return <- create Collection()
    }

    init() {
        self.totalTenants = 0

        self.TenantCollectionStoragePath = /storage/HyperverseServiceTenantCollection
        self.TenantCollectionPublicPath = /public/HyperverseServiceTenantCollection
    }
}