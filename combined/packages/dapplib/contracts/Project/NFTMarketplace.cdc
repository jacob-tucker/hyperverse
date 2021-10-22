import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import SimpleFT from "./SimpleFT.cdc"

// THIS DOES IMPLEMENT IHyperverseModule BECAUSE IT IS A SECONDARY EXPORT (aka Module).
// IT DOES IMPLEMENT IHyperverseComposable BECAUSE IT'S A SMART COMPOSABLE CONTRACT.
pub contract NFTMarketplace: IHyperverseModule, IHyperverseComposable {

    /**************************************** METADATA ****************************************/

    // ** MUST be access(contract) **
    access(contract) let metadata: HyperverseModule.ModuleMetadata
    pub fun getMetadata(): HyperverseModule.ModuleMetadata {
        return self.metadata
    }

    /**************************************** TENANT ****************************************/

    pub var totalTenants: UInt64
    access(contract) var tenants: @{UInt64: Tenant{IHyperverseComposable.ITenant, IState}}
    pub fun getTenant(id: UInt64): &Tenant{IHyperverseComposable.ITenant, IState} {
        return &self.tenants[id] as &Tenant{IHyperverseComposable.ITenant, IState}
    }

    // All of the getters and setters.
    // ** Setters MUST be access(contract) or access(account) **
    pub resource interface IState {
        pub var holder: Address
        pub let SNFTTenantID: UInt64 
        pub let SFTTenantID: UInt64
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let id: UInt64 
        pub var holder: Address

        pub let SNFTTenantID: UInt64
        pub let SFTTenantID: UInt64

        init(_tenantID: UInt64, _holder: Address, _SNFTTenantID: UInt64, _SFTTenantID: UInt64) {
            self.id = _tenantID
            self.holder = _holder
            self.SNFTTenantID = _SNFTTenantID
            self.SFTTenantID = _SFTTenantID
        }
    }

    pub fun instance(package: &Package): UInt64 {
        let tenantID = NFTMarketplace.totalTenants
        NFTMarketplace.totalTenants = NFTMarketplace.totalTenants + (1 as UInt64)

        // This will give the caller's `package` a SimpleNFT.Admin and a SimpleNFT.NFTMinter
        // inside their SimpleNFT.Package at the `SNFTTenantID`. 
        let SNFTTenantID = SimpleNFT.instance(package: package.SimpleNFTPackage.borrow()!)
        let SFTTenantID = SimpleFT.instance(package: package.SimpleFTPackage.borrow()!)

        NFTMarketplace.tenants[tenantID] <-! create Tenant(_tenantID: tenantID, _holder: package.owner!.address, _SNFTTenantID: SNFTTenantID, _SFTTenantID: SFTTenantID)

        return tenantID
    }

    /**************************************** PACKAGE ****************************************/

    // Named Paths
    //
    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
    // Any things that should be linked to the public
    pub resource interface PackagePublic {
       pub fun SimpleNFTPackagePublic(): &SimpleNFT.Package{SimpleNFT.PackagePublic}
       pub fun SimpleFTPackagePublic(): &SimpleFT.Package{SimpleFT.PackagePublic}
       pub fun borrowSaleCollectionPublic(tenantID: UInt64): &SaleCollection{SalePublic}
    }
    // Need to include the dependency's package here
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

            self.SimpleFTPackage.borrow()!.setup(tenantID: tenant.SFTTenantID)
            self.SimpleNFTPackage.borrow()!.setup(tenantID: tenant.SNFTTenantID)
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

            var ownedNFTs = self.SimpleNFTPackage.borrow()!.borrowCollection(tenantID: NFTMarketplace.getTenant(id: self.tenantID).SNFTTenantID).getIDs()
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

            let vaultRef = self.SimpleFTPackage.borrow()!.borrowVaultPublic(tenantID: NFTMarketplace.getTenant(id: self.tenantID).SFTTenantID)
            
            vaultRef.deposit(vault: <-buyTokens)
    
            let token <- self.SimpleNFTPackage.borrow()!.borrowCollection(tenantID: NFTMarketplace.getTenant(id: self.tenantID).SNFTTenantID).withdraw(withdrawID: id)

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
        self.totalTenants = 0
        self.tenants <- {}

        // Set our named paths
        self.PackageStoragePath = /storage/NFTMarketplacePackage
        self.PackagePrivatePath = /private/NFTMarketplacePackage
        self.PackagePublicPath = /public/NFTMarketplacePackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "NFT Marketplace", 
            _authors: [HyperverseModule.Author(_address: 0xe37a242dfff69bbc, _externalLink: "https://localhost:5000/externalMetadata")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _tenantStoragePath: /storage/NFTMarketplaceTenant,
            _tenantPublicPath: /public/NFTMarketplaceTenant,
            _externalLink: "https://externalLink.net/1234567890",
            _secondaryModules: [{self.account.address: "MorganNFT"}]
        )

        emit NFTMarketplaceInitialized()
    }
}