import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import SimpleFT from "./SimpleFT.cdc"

pub contract NFTMarketplace: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: UInt64)
    access(contract) var clientTenants: {Address: UInt64}
    pub fun getClientTenants(): {Address: UInt64} {
        return self.clientTenants
    }
    access(contract) var tenants: @{UInt64: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: UInt64): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    pub resource interface IState {
        pub let tenantID: UInt64
        pub var holder: Address
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: UInt64
        pub var holder: Address

        init(_tenantID: UInt64, _holder: Address) {
            self.tenantID = _tenantID
            self.holder = _holder
        }
    }

    pub fun instance(package: &Package, uid: &HyperverseModule.UniqueID): UInt64 {
        pre {
            uid.dependency || NFTMarketplace.clientTenants[package.owner!.address] == nil:
                "This user already owns a Tenant from this contract!"
        }
        var tenantID: UInt64 = uid.uuid
        let newTenant <- create Tenant(_tenantID: tenantID, _holder: package.owner!.address)
        NFTMarketplace.tenants[tenantID] <-! newTenant
        emit TenantCreated(id: tenantID)

        if !uid.dependency {
            NFTMarketplace.clientTenants[package.owner!.address] = tenantID
            uid.dependency = true
        }
        SimpleNFT.instance(package: package.SimpleNFTPackage.borrow()!, uid: uid)
        SimpleFT.instance(package: package.SimpleFTPackage.borrow()!, uid: uid)
        return tenantID
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
   
    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}
       pub fun SimpleFTPackagePublic(): &SimpleFT.Package{SimpleFT.PackagePublic}
       pub fun borrowSaleCollectionPublic(tenantID: UInt64): &SaleCollection{SalePublic}
    }
    
    pub resource Package: PackagePublic {
        pub let SimpleNFTPackage: Capability<&SimpleNFT.Package>
        pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic} {
            return self.SimpleNFTPackage.borrow()! as &SimpleNFT.Package{SimpleNFT.PackagePublic}
        }
        pub let SimpleFTPackage: Capability<&SimpleFT.Package>
        pub fun SimpleFTPackagePublic(): &SimpleFT.Package{SimpleFT.PackagePublic} {
            return self.SimpleFTPackage.borrow()! as &SimpleFT.Package{SimpleFT.PackagePublic}
        }

        pub var salecollections: @{UInt64: SaleCollection}
    
        pub fun setup(tenantID: UInt64) {
            self.salecollections[tenantID] <-! create SaleCollection(tenantID, _nftPackage: self.SimpleNFTPackage, _ftPackage: self.SimpleFTPackage)
            let tenant = NFTMarketplace.getTenant(id: tenantID)

            self.SimpleFTPackage.borrow()!.setup(tenantID: tenantID)
            self.SimpleNFTPackage.borrow()!.setup(tenantID: tenantID)
        }

        pub fun borrowSaleCollection(tenantID: UInt64): &SaleCollection {
            return &self.salecollections[tenantID] as &SaleCollection
        }
        pub fun borrowSaleCollectionPublic(tenantID: UInt64): &SaleCollection{SalePublic} {
            return &self.salecollections[tenantID] as &SaleCollection{SalePublic}
        }

        init(
            _SimpleNFTPackage: Capability<&SimpleNFT.Package>, 
            _SimpleFTPackage: Capability<&SimpleFT.Package>) 
        {
            self.SimpleNFTPackage = _SimpleNFTPackage
            self.SimpleFTPackage = _SimpleFTPackage
            self.salecollections <- {} 
        }

        destroy() {
            destroy self.salecollections
        }
    }

    pub fun getPackage(
        SimpleNFTPackage: Capability<&SimpleNFT.Package>, 
        SimpleFTPackage: Capability<&SimpleFT.Package>
    ): @Package {
        pre {
            SimpleNFTPackage.borrow() != nil: "This is not a correct SimpleNFT.Package! Or you don't have one yet."
        }
        return <- create Package(_SimpleNFTPackage: SimpleNFTPackage, _SimpleFTPackage: SimpleFTPackage)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event NFTMarketplaceInitialized()

    pub event ForSale(id: UInt64, price: UFix64)

    pub event NFTPurchased(id: UInt64, price: UFix64)

    pub event SaleWithdrawn(id: UInt64)

    pub resource interface SalePublic {
        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @SimpleFT.Vault)
        pub fun idPrice(id: UInt64): UFix64?
        pub fun getIDs(): [UInt64]
    }

    pub resource SaleCollection: SalePublic {
        pub let tenantID: UInt64
        pub var forSale: {UInt64: UFix64}
        access(self) let SimpleFTPackage: Capability<&SimpleFT.Package>
        access(self) let SimpleNFTPackage: Capability<&SimpleNFT.Package>

        init (_ tenantID: UInt64, _nftPackage: Capability<&SimpleNFT.Package>, _ftPackage: Capability<&SimpleFT.Package>,) {
            self.tenantID = tenantID
            self.forSale = {}
            self.SimpleFTPackage = _ftPackage
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

        pub fun purchase(id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @SimpleFT.Vault) {
            pre {
                self.forSale[id] != nil:
                    "No NFT matching this id for sale!"
                buyTokens.balance >= (self.forSale[id]!):
                    "Not enough tokens to buy the NFT!"
            }

            let price = self.forSale[id]!
            let vaultRef = self.SimpleFTPackage.borrow()!.borrowVaultPublic(tenantID: self.tenantID)
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
        /* For Secondary Export */
        self.clientTenants = {}
        self.tenants <- {}

        // Set our named paths
        self.PackageStoragePath = /storage/NFTMarketplacePackage
        self.PackagePrivatePath = /private/NFTMarketplacePackage
        self.PackagePublicPath = /public/NFTMarketplacePackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "NFT Marketplace", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalLink: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalLink: "",
            _secondaryModules: [{Address(0xe37a242dfff69bbc): "SimpleNFT", 0xe37a242dfff69bbc: "SimpleFT"}]
        )

        emit NFTMarketplaceInitialized()
    }
}