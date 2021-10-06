import HyperverseService from "../HyperverseService.cdc"
import IHyperverseComposable from "../IHyperverseComposable.cdc"
import IHyperverseModule from "../IHyperverseModule.cdc"
import HyperverseModule from "../HyperverseModule.cdc"
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
    
    /* Requirements for the IHyperverseComposable */

    // the total number of tenants that have been created
    pub var totalTenants: UInt64

    // All of the client Tenants (represented by Addresses) that 
    // have an instance of an Tenant and how many they have. 
    access(contract) var clientTenants: {Address: UInt64}
    
    pub resource Tenant: IHyperverseComposable.ITenant {
        pub let id: UInt64 

        pub let authNFT: Capability<&HyperverseService.AuthNFT>

        /* For NFTMarketplace Functionality */
        pub let nftTenant: @MorganNFT.Tenant

        init(_authNFT: Capability<&HyperverseService.AuthNFT>) {
            /* For Composability */
            self.id = NFTMarketplace.totalTenants
            NFTMarketplace.totalTenants = NFTMarketplace.totalTenants + (1 as UInt64)
            self.authNFT = _authNFT

            /* For NFTMarketplace Functionality */
            self.nftTenant <- MorganNFT.instance(authNFT: _authNFT)
            
        }

        destroy() {
            destroy self.nftTenant
        }
    }

    pub fun instance(authNFT: Capability<&HyperverseService.AuthNFT>): @Tenant {
        let clientTenant = authNFT.borrow()!.owner!.address
        if let count = self.clientTenants[clientTenant] {
            self.clientTenants[clientTenant] = self.clientTenants[clientTenant]! + (1 as UInt64)
        } else {
            self.clientTenants[clientTenant] = (1 as UInt64)
        }

        return <-create Tenant(_authNFT: authNFT)
    }

    pub fun getTenants(): {Address: UInt64} {
        return self.clientTenants
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
        self.clientTenants = {}
        self.totalTenants = 0

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "NFT Marketplace", 
            _authors: [HyperverseModule.Author(_address: 0x1, _external: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: 1632887513,
            _tenantStoragePath: /storage/NFTMarketplaceTenant,
            _external: "https://externalLink.net/1234567890",
            _secondaryModules: ["MorganNFT.cdc"]
        )

        emit NFTMarketplaceInitialized()
    }
}