import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import SimpleToken from "./SimpleToken.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"
import HFungibleToken from "../Hyperverse/HFungibleToken.cdc"

pub contract NFTMarketplace: IHyperverseComposable {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(tenant: Address)
    
    access(contract) var tenants: @{Address: IHyperverseComposable.Tenant}
    access(contract) fun getTenant(tenant: Address): &Tenant {
        let ref = &self.tenants[tenant] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    pub fun tenantExists(tenant: Address): Bool {
        return self.tenants[tenant] != nil
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant {
        pub var holder: Address

        init(_holder: Address) {
            self.holder = _holder
        }
    }

    pub fun createTenant(auth: &HyperverseAuth.Auth) {
        let tenant = auth.owner!.address
        
        /* Dependencies */
        if !SimpleToken.tenantExists(tenant: tenant) {
            SimpleToken.createTenant(auth: auth, initialSupply: 0.0)               
        }

        if !SimpleNFT.tenantExists(tenant: tenant) {
            SimpleNFT.createTenant(auth: auth)                   
        }

        self.tenants[tenant] <-! create Tenant(_holder: tenant)
        
        emit TenantCreated(tenant: tenant)
    }

    /**************************************** BUNDLE ****************************************/

    pub let BundleStoragePath: StoragePath
    pub let BundlePrivatePath: PrivatePath
    pub let BundlePublicPath: PublicPath
   
    pub resource interface PublicBundle {
       pub fun borrowSaleCollectionPublic(tenant: Address): &SaleCollection{SalePublic}
    }
    
    pub resource Bundle: PublicBundle {
        pub let auth: Capability<&HyperverseAuth.Auth>

        pub var salecollections: @{Address: SaleCollection}

        pub fun borrowSaleCollection(tenant: Address): &SaleCollection {
            if self.salecollections[tenant] == nil {
                self.salecollections[tenant] <-! create SaleCollection(tenant, _auth: self.auth)
            }
            return &self.salecollections[tenant] as &SaleCollection
        }
        pub fun borrowSaleCollectionPublic(tenant: Address): &SaleCollection{SalePublic} {
            return self.borrowSaleCollection(tenant: tenant)
        }

        init(_auth: Capability<&HyperverseAuth.Auth>) 
        {
            self.salecollections <- {} 
            self.auth = _auth
        }

        destroy() {
            destroy self.salecollections
        }
    }

    pub fun getBundle(auth: Capability<&HyperverseAuth.Auth>): @Bundle {
        return <- create Bundle(_auth: auth)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event NFTMarketplaceInitialized()

    pub event ForSale(id: UInt64, price: UFix64)

    pub event NFTPurchased(id: UInt64, price: UFix64)

    pub event SaleWithdrawn(id: UInt64)

    pub resource interface SalePublic {
        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @HFungibleToken.Vault)
        pub fun idPrice(id: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
    }

    pub resource SaleCollection: SalePublic {
        pub let tenant: Address
        pub var forSale: {UInt64: UFix64}
        access(self) let auth: Capability<&HyperverseAuth.Auth>

        init (_ tenant: Address, _auth: Capability<&HyperverseAuth.Auth>) {
            self.tenant = tenant
            self.forSale = {}
            self.auth = _auth
            
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
            let simpleNFT = self.auth.borrow()!.getBundle(bundleName: SimpleNFT.getType().identifier) as! &SimpleNFT.Bundle
            var ownedNFTs = simpleNFT.borrowCollection(tenant: self.tenant).getIDs()
            for id in ids {
                if (ownedNFTs.contains(id)) {
                    self.forSale[id] = price

                    emit ForSale(id: id, price: price)
                }
            }
        }

        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @HFungibleToken.Vault) {
            pre {
                buyTokens.isInstance(Type<@SimpleToken.Vault>()):
                    "Not a SimpleToken Vault"
                self.forSale[id] != nil:
                    "No NFT matching this id for sale!"
                buyTokens.balance >= (self.forSale[id]!):
                    "Not enough tokens to buy the NFT!"
            }

            let price = self.forSale[id]!

            let simpleToken = self.auth.borrow()!.getBundle(bundleName: SimpleToken.getType().identifier) as! &SimpleToken.Bundle
            let vaultRef = simpleToken.borrowVaultPublic(tenant: self.tenant)
            vaultRef.deposit(from: <-buyTokens)

            let simpleNFT = self.auth.borrow()!.getBundle(bundleName: SimpleNFT.getType().identifier) as! &SimpleNFT.Bundle
            let token <- simpleNFT.borrowCollection(tenant: self.tenant).withdraw(withdrawID: id)
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

    init() {
        self.tenants <- {}

        self.BundleStoragePath = /storage/NFTMarketplaceBundle
        self.BundlePrivatePath = /private/NFTMarketplaceBundle
        self.BundlePublicPath = /public/NFTMarketplaceBundle

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "NFT Marketplace", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalLink: "",
                _secondaryModules: [{Address(0x26a365de6d6237cd): "SimpleNFT", 0x26a365de6d6237cd: "SimpleToken"}]
            )
        )

        emit NFTMarketplaceInitialized()
    }
}