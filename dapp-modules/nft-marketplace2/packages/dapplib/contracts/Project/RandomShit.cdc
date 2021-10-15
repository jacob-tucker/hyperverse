import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import NFTMarketplace from "./NFTMarketplace.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract RandomShit: IHyperverseModule, IHyperverseComposable {

    // must be access(contract) because dictionaries can be
    // changed if they're pub
    access(contract) let metadata: HyperverseModule.ModuleMetadata

    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }
    
    /* Requirements for the IHyperverseComposable */

    pub var totalTenants: UInt64

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}

    pub resource interface ITenantState {
        pub fun nftMarketplaceTenantState(): &NFTMarketplace.Tenant{NFTMarketplace.ITenantState}
        // All other dependency ITenantState functions would have to be here
    }
    
    pub resource Tenant: IHyperverseComposable.ITenantID, ITenantState {
        pub let id: UInt64

        pub let nftMarketplace: @NFTMarketplace.Tenant

        pub fun nftMarketplaceTenantState(): &NFTMarketplace.Tenant{NFTMarketplace.ITenantState} {
            return &self.nftMarketplace as &NFTMarketplace.Tenant{NFTMarketplace.ITenantState}
        }

        init(_tenantID: UInt64) {
            /* For Composability */
            self.id = _tenantID

            self.nftMarketplace <- NFTMarketplace.instance() 
        }

        destroy() {
            destroy self.nftMarketplace
        }
    }

    pub fun instance(): @Tenant {
        let tenantID = RandomShit.totalTenants

        RandomShit.totalTenants = RandomShit.totalTenants + (1 as UInt64)

        return <-create Tenant(_tenantID: tenantID)
    }

    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
    }

    pub let TenantCollectionStoragePath: StoragePath
    pub let TenantCollectionPublicPath: PublicPath

    pub resource TenantCollection: IHyperverseComposable.ITenantCollectionPublic {
        // dictionary of Tenant conforming tenants
        pub var ownedTenants: @{UInt64: IHyperverseComposable.Tenant}

        // deposit takes a Tenant and adds it to the ownedTenants dictionary
        // and adds the tenantID to the key
        pub fun deposit(tenant: @IHyperverseComposable.Tenant) {
            let tenant <- tenant as! @Tenant

            let id: UInt64 = tenant.id

            // add the new token to the dictionary which removes the old one
            let oldToken <- self.ownedTenants[id] <- tenant

            destroy oldToken
        }

        pub fun getTenantIDs(): [UInt64] {
            return self.ownedTenants.keys
        }

        pub fun borrowTenant(tenantID: UInt64): &IHyperverseComposable.Tenant {
            return &self.ownedTenants[tenantID] as &IHyperverseComposable.Tenant
        }

        pub fun borrowTenantState(tenantID: UInt64): &Tenant{ITenantState} {
            let ref = &self.ownedTenants[tenantID] as auth &IHyperverseComposable.Tenant
            let ref2 = ref as! &Tenant
            return ref2 as &Tenant{ITenantState}
        }

        init () {
            self.ownedTenants <- {}
        }

        destroy() {
            destroy self.ownedTenants
        }
    } 

    /* Functionality of the RandomShit Module */


    init() {
        /* For Secondary Export */
        self.totalTenants = 0
        self.clientTenants = {}

        // Set our named paths
        self.TenantCollectionStoragePath = /storage/TenantNFTMarketplaceCollection
        self.TenantCollectionPublicPath = /public/TenantNFTMarketplaceCollection

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "NFT Marketplace", 
            _authors: [HyperverseModule.Author(_address: 0x1, _externalURI: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: 1632887513,
            _tenantStoragePath: /storage/NFTMarketplaceTenant,
            _tenantPublicPath: /public/NFTMarketplaceTenant,
            _externalURI: "https://externalLink.net/1234567890",
            _secondaryModules: [{self.account.address: "MorganNFT"}]
        )
    }
}