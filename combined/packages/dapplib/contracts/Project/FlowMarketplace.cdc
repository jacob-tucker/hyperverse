import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import FlowToken from "../Flow/FlowToken.cdc"
import FungibleToken from "../Flow/FungibleToken.cdc"

pub contract FlowMarketplace: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    pub event TenantReused(id: String)
    access(contract) var clientTenants: {Address: [String]}
    pub fun getClientTenants(account: Address): [String] {
        return self.clientTenants[account]!
    }
    access(contract) var tenants: @{String: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }
    access(contract) var aliases: {String: String}
    access(contract) fun addAlias(original: String, new: String) {
        pre {
            self.tenants[original] != nil: "Original tenantID does not exist."
        }
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

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
   
    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}
       pub fun borrowSaleCollectionPublic(tenantID: String): &SaleCollection{SalePublic}
    }
    
    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }
        pub let FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>

        pub var salecollections: @{String: SaleCollection}

        pub fun instance(tenantID: UInt64, SimpleNFTID: UInt64?) {
            var STenantID: String = self.owner!.address.toString().concat(".").concat(tenantID.toString())
            
            /* Dependencies */
            if SimpleNFTID == nil {
                self.SimpleNFTPackage.borrow()!.instance(tenantID: tenantID)
            } else {
                self.SimpleNFTPackage.borrow()!.addAlias(original: SimpleNFTID!, new: tenantID)
            }
            FlowMarketplace.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: self.owner!.address)
            FlowMarketplace.addAlias(original: STenantID, new: STenantID)
            emit TenantCreated(id: STenantID)

            if FlowMarketplace.clientTenants[self.owner!.address] != nil {
                FlowMarketplace.clientTenants[self.owner!.address]!.append(STenantID)
            } else {
                FlowMarketplace.clientTenants[self.owner!.address] = [STenantID]
            }
        }

        pub fun addAlias(original: UInt64, new: UInt64) {
            let originalID = self.owner!.address.toString().concat(".").concat(original.toString())
            let newID = self.owner!.address.toString().concat(".").concat(new.toString())
            
            FlowMarketplace.addAlias(original: originalID, new: newID)
            emit TenantReused(id: originalID)
        }
    
        pub fun setup(tenantID: String) {
            pre {
                FlowMarketplace.tenants[tenantID] != nil: "This tenantID does not exist."
            }
            self.salecollections[tenantID] <-! create SaleCollection(tenantID, _nftPackage: self.SimpleNFTPackage, _ftVault: self.FlowTokenVault)
        }

        pub fun borrowSaleCollection(tenantID: String): &SaleCollection {
            let original = FlowMarketplace.aliases[tenantID]!
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
            _FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) 
        {
            self.SimpleNFTPackage = _SimpleNFTPackage
            self.FlowTokenVault = _FlowTokenVault
            self.salecollections <- {} 
        }

        destroy() {
            destroy self.salecollections
        }
    }

    pub fun getPackage(
        SimpleNFTPackage: Capability<&SimpleNFT.Package>,
        FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    ): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package! Or you don't have one yet."
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage, _FlowTokenVault: FlowTokenVault)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event FlowMarketplaceInitialized()

    pub event ForSale(id: UInt64, price: UFix64)

    pub event NFTPurchased(id: UInt64, price: UFix64)

    pub event SaleWithdrawn(id: UInt64)

    pub resource interface SalePublic {
        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @FungibleToken.Vault)
        pub fun idPrice(id: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
    }

    pub resource SaleCollection: SalePublic {
        pub let tenantID: String
        pub var forSale: {UInt64: UFix64}
        access(self) let FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
        access(self) let SimpleNFTPackage: Capability<&SimpleNFT.Package>

        init (_ tenantID: String, _nftPackage: Capability<&SimpleNFT.Package>, _ftVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>,) {
            self.tenantID = tenantID
            self.forSale = {}
            self.FlowTokenVault = _ftVault
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

        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @FungibleToken.Vault) {
            pre {
                self.forSale[id] != nil:
                    "No NFT matching this id for sale!"
                buyTokens.balance >= (self.forSale[id]!):
                    "Not enough tokens to buy the NFT!"
            }
            let buyTokens <- buyTokens as! @FlowToken.Vault
            let price = self.forSale[id]!
            let vaultRef = self.FlowTokenVault.borrow()!
            vaultRef.deposit(from: <-buyTokens)
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

        self.PackageStoragePath = /storage/FlowMarketplacePackage
        self.PackagePrivatePath = /private/FlowMarketplacePackage
        self.PackagePublicPath = /public/FlowMarketplacePackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "Flow Marketplace", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: [{Address(0x26a365de6d6237cd): "SimpleNFT"}]
        )

        emit FlowMarketplaceInitialized()
    }
}