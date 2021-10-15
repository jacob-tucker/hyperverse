import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import MorganNFT from "./MorganNFT.cdc"
import FlowToken from "../Flow/FlowToken.cdc"
import FungibleToken from "../Flow/FungibleToken.cdc"
import NonFungibleToken from "../Flow/NonFungibleToken.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract NFTMarketplace: IHyperverseModule, IHyperverseComposable {

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
        pub fun morganNFTTenantState(): &MorganNFT.Tenant{MorganNFT.ITenantState}
        // All other dependency ITenantState functions would have to be here
    }
    
    pub resource Tenant: IHyperverseComposable.ITenantID, ITenantState {
        pub let id: UInt64

        pub let morganNFT: @MorganNFT.Tenant

        pub fun morganNFTTenantState(): &MorganNFT.Tenant{MorganNFT.ITenantState} {
            return &self.morganNFT as &MorganNFT.Tenant{MorganNFT.ITenantState}
        }

        init(_tenantID: UInt64) {
            /* For Composability */
            self.id = _tenantID

            self.morganNFT <- MorganNFT.instance() 
        }

        destroy() {
            destroy self.morganNFT
        }
    }

    pub fun instance(): @Tenant {
        let tenantID = MorganNFT.totalTenants

        NFTMarketplace.totalTenants = NFTMarketplace.totalTenants + (1 as UInt64)

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

    /* Functionality of the NFTMarketplace Module */

    pub event NFTMarketplaceInitialized()

    pub event ForSale(id: UInt64, price: UFix64)

    pub event NFTPurchased(id: UInt64, price: UFix64)

    pub event SaleWithdrawn(id: UInt64)

    pub resource interface SalePublic {
        pub fun purchase(id: UInt64, recipient: &MorganNFT.Collection{NonFungibleToken.CollectionPublic}, buyTokens: @FlowToken.Vault)
        pub fun idPrice(id: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
    }

    pub resource SaleCollection: SalePublic {

        pub var forSale: {UInt64: UFix64}

        access(self) let ownerVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>

        access(self) let ownerCollection: Capability<&MorganNFT.Collection>

        init (_vault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>, _collection: Capability<&MorganNFT.Collection>) {
            self.forSale = {}
            self.ownerVault = _vault
            self.ownerCollection = _collection
        }

        pub fun unlistSale(id: UInt64) {
            self.forSale[id] = nil

            emit SaleWithdrawn(id: id)
        }

        pub fun listForSale(ids: [UInt64], price: UFix64) {
            pre {
                price > 0.0:
                    "Cannot list a NFT for 0.0"
            }

            var ownedNFTs = self.ownerCollection.borrow()!.getIDs()
            for id in ids {
                if (ownedNFTs.contains(id)) {
                    self.forSale[id] = price

                    emit ForSale(id: id, price: price)
                }
            }
        }

        pub fun purchase(id: UInt64, recipient: &MorganNFT.Collection{NonFungibleToken.CollectionPublic}, buyTokens: @FlowToken.Vault) {
            pre {
                self.forSale[id] != nil:
                    "No NFT matching this id for sale!"
                buyTokens.balance >= (self.forSale[id]!):
                    "Not enough tokens to buy the NFT!"
            }

            let price = self.forSale[id]!

            let vaultRef = self.ownerVault.borrow()
                ?? panic("Could not borrow reference to owner token vault")
            
            vaultRef.deposit(from: <-buyTokens)
    
            let token <- self.ownerCollection.borrow()!.withdraw(withdrawID: id)

            recipient.deposit(token: <-token)

            self.unlistSale(id: id)

            emit NFTPurchased(id: id, price: price)
        }

        pub fun idPrice(id: UInt64): UFix64? {
            return self.forSale[id]
        }

        pub fun getIDs(): [UInt64] {
            return self.forSale.keys
        }
    }

    pub fun createSaleCollection(ownerVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>, ownerCollection: Capability<&MorganNFT.Collection>): @SaleCollection {
        return <- create SaleCollection(_vault: ownerVault, _collection: ownerCollection)
    }

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

        emit NFTMarketplaceInitialized()
    }
}