import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import SimpleToken from "./SimpleToken.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"

pub contract NFTMarketplace: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    access(contract) var clientTenants: {Address: String}
    pub fun getClientTenantID(account: Address): String? {
        return self.clientTenants[account]
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }
    access(contract) var aliases: {String: String}
    pub fun addAlias(auth: &HyperverseAuth.Auth, new: String) {
        let original = auth.owner!.address.toString()
                        .concat(".")
                        .concat(self.getType().identifier)

        self.aliases[new] = original
    }



    pub resource interface IState {
        pub let tenantID: String
        pub var holder: Address
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var holder: Address

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
        }
    }

    pub fun instance(auth: &HyperverseAuth.Auth) {
        pre {
            self.clientTenants[auth.owner!.address] == nil: "This account already have a Tenant from this contract."
        }

        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)
        
        /* Dependencies */
        if SimpleToken.getClientTenantID(account: auth.owner!.address) == nil {
            SimpleToken.instance(auth: auth)                   
        }
        SimpleToken.addAlias(auth: auth, new: STenantID)

        if SimpleNFT.getClientTenantID(account: auth.owner!.address) == nil {
            SimpleNFT.instance(auth: auth)                   
        }
        SimpleNFT.addAlias(auth: auth, new: STenantID)
        

        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: auth.owner!.address)
        self.addAlias(auth: auth, new: STenantID)
        
        self.clientTenants[auth.owner!.address] = STenantID
        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
   
    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}
       pub fun SimpleTokenPackagePublic(): &SimpleToken.Package{SimpleToken.PackagePublic}
       pub fun borrowSaleCollectionPublic(tenantID: String): &SaleCollection{SalePublic}
    }
    
    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }
        pub let SimpleTokenPackage: Capability<&SimpleToken.Package>
        pub fun SimpleTokenPackagePublic(): &SimpleToken.Package{SimpleToken.PackagePublic} {
            return self.SimpleTokenPackage.borrow()! as &SimpleToken.Package{SimpleToken.PackagePublic}
        }

        pub var salecollections: @{String: SaleCollection}
    
        pub fun setup(tenantID: String) {
            pre {
                NFTMarketplace.tenants[tenantID] != nil: "This tenantID does not exist."
            }
            self.salecollections[tenantID] <-! create SaleCollection(tenantID, _nftPackage: self.SimpleNFTPackage, _ftPackage: self.SimpleTokenPackage)
        }

        pub fun borrowSaleCollection(tenantID: String): &SaleCollection {
            let original = NFTMarketplace.aliases[tenantID]!
            if self.salecollections[original] == nil {
                self.setup(tenantID: original)
            }
            return &self.salecollections[original] as &SaleCollection
        }
        pub fun borrowSaleCollectionPublic(tenantID: String): &SaleCollection{SalePublic} {
            return self.borrowSaleCollection(tenantID: tenantID)
        }

        init(
            _SimpleNFTPackage: Capability<&SimpleNFT.Package>, 
            _SimpleTokenPackage: Capability<&SimpleToken.Package>) 
        {
            self.SimpleNFTPackage = _SimpleNFTPackage
            self.SimpleTokenPackage = _SimpleTokenPackage
            self.salecollections <- {} 
        }

        destroy() {
            destroy self.salecollections
        }
    }

    pub fun getPackage(
        SimpleNFTPackage: Capability<&SimpleNFT.Package>, 
        SimpleTokenPackage: Capability<&SimpleToken.Package>
    ): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package! Or you don't have one yet."
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage, _SimpleTokenPackage: SimpleTokenPackage)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event NFTMarketplaceInitialized()

    pub event ForSale(id: UInt64, price: UFix64)

    pub event NFTPurchased(id: UInt64, price: UFix64)

    pub event SaleWithdrawn(id: UInt64)

    pub resource interface SalePublic {
        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @SimpleToken.Vault)
        pub fun idPrice(id: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
    }

    pub resource SaleCollection: SalePublic {
        pub let tenantID: String
        pub var forSale: {UInt64: UFix64}
        access(self) let SimpleTokenPackage: Capability<&SimpleToken.Package>
        access(self) let SimpleNFTPackage: Capability<&SimpleNFT.Package>

        init (_ tenantID: String, _nftPackage: Capability<&SimpleNFT.Package>, _ftPackage: Capability<&SimpleToken.Package>,) {
            self.tenantID = tenantID
            self.forSale = {}
            self.SimpleTokenPackage = _ftPackage
            self.SimpleNFTPackage = _nftPackage
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

            var ownedNFTs = self.SimpleNFTPackage.borrow()!.borrowCollection(tenantID: self.tenantID).getIDs()
            for id in ids {
                if (ownedNFTs.contains(id)) {
                    self.forSale[id] = price

                    emit ForSale(id: id, price: price)
                }
            }
        }

        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @SimpleToken.Vault) {
            pre {
                self.forSale[id] != nil:
                    "No NFT matching this id for sale!"
                buyTokens.balance >= (self.forSale[id]!):
                    "Not enough tokens to buy the NFT!"
            }

            let price = self.forSale[id]!
            let vaultRef = self.SimpleTokenPackage.borrow()!.borrowVaultPublic(tenantID: self.tenantID)
            vaultRef.deposit(vault: <-buyTokens)
            let token <- self.SimpleNFTPackage.borrow()!.borrowCollection(tenantID: self.tenantID).withdraw(withdrawID: id)
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
        self.clientTenants = {}
        self.tenants <- {}
        self.aliases = {}

        self.PackageStoragePath = /storage/NFTMarketplacePackage
        self.PackagePrivatePath = /private/NFTMarketplacePackage
        self.PackagePublicPath = /public/NFTMarketplacePackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "NFT Marketplace", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: [{Address(0x26a365de6d6237cd): "SimpleNFT", 0x26a365de6d6237cd: "SimpleToken"}]
        )

        emit NFTMarketplaceInitialized()
    }
}