import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import SimpleNFT from "./SimpleNFT.cdc"
import FlowToken from "../Flow/FlowToken.cdc"
import FungibleToken from "../Flow/FungibleToken.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import Registry from "../Hyperverse/Registry.cdc"

pub contract SimpleNFTMarketplace: IHyperverseComposable {

    /**************************************** TENANT ****************************************/

    pub event TenantCreated(id: String)
    pub fun clientTenantID(account: Address): String {
        return account.toString().concat(".").concat(self.getType().identifier)
    }
    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun tenantExists(account: Address): Bool {
        return self.tenants[self.clientTenantID(account: account)] != nil
    }
    pub fun getTenant(account: Address): &Tenant {
        let ref = &self.tenants[self.clientTenantID(account: account)] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    
    pub resource Tenant: IHyperverseComposable.ITenant {
        pub let tenant: String
        pub var holder: Address

        init(_tenantID: String, _holder: Address) {
            self.tenant = _tenantID
            self.holder = _holder
        }
    }

    pub fun instance(auth: &HyperverseAuth.Auth) {
        // If Jacob is the one calling instance...  
        // STenantID = "{Jacob's Address}.A.{Address of Contract}.{SimpleNFTMarketplace}
        // JacobsAddress.A.AddressOfContract.SimpleNFTMarketplace
        let tenant = auth.owner!.address
        var STenantID: String = self.clientTenantID(account: tenant)

        /* Dependencies */
        if SimpleNFT.getTenant(account: tenant) == nil {
            SimpleNFT.instance(auth: auth)                
        }
        
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: tenant)
        
        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath
   
    pub resource interface PackagePublic {
       pub fun borrowSaleCollectionPublic(tenant: Address): &SaleCollection{SalePublic}
    }
    
    // For users... so they will need a SimpleNFTPackage because then why else would you
    // be creating a Storefront. You're creating a storefront for YOUR NFTs, so those
    // NFTs must already exist.
    pub resource Package: PackagePublic {
        pub let auth: Capability<&HyperverseAuth.Auth>
        pub let FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>

        pub var salecollections: @{Address: SaleCollection}

        pub fun borrowSaleCollection(tenant: Address): &SaleCollection {
            if self.salecollections[tenant] == nil {
                self.salecollections[tenant] <-! create SaleCollection(tenant, _auth: self.auth, _ftVault: self.FlowTokenVault)
            }
            return &self.salecollections[tenant] as &SaleCollection
        }
        pub fun borrowSaleCollectionPublic(tenant: Address): &SaleCollection{SalePublic} {
            return self.borrowSaleCollection(tenant: tenant)
        }

        init(
            _auth: Capability<&HyperverseAuth.Auth>,
            _FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) 
        {
            self.auth = _auth
            self.FlowTokenVault = _FlowTokenVault
            self.salecollections <- {} 
        }

        destroy() {
            destroy self.salecollections
        }
    }

    pub fun getPackage(
        auth: Capability<&HyperverseAuth.Auth>,
        FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
    ): @Package {
        return <- create Package(_auth: auth, _FlowTokenVault: FlowTokenVault)
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event SimpleNFTMarketplaceInitialized()

    pub event ForSale(id: UInt64, price: UFix64)

    pub event NFTPurchased(id: UInt64, price: UFix64)

    pub event SaleWithdrawn(id: UInt64)

    pub resource interface SalePublic {
        pub fun purchase(simpleNFTTenant: Address, id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @FungibleToken.Vault)
        pub fun idPrice(simpleNFTTenant: Address, id: UInt64): UFix64?
        pub fun getIDs(simpleNFTTenant: Address): [UInt64]
    }

    pub resource SaleCollection: SalePublic {
        pub let tenant: Address
        pub var forSale: {Address: {UInt64: UFix64}}
        access(self) let FlowTokenVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>
        access(self) let SimpleNFTPackage: Capability<&SimpleNFT.Package>

        init (_ tenant: Address, _auth: Capability<&HyperverseAuth.Auth>, _ftVault: Capability<&FlowToken.Vault{FungibleToken.Receiver}>) {
            self.tenant = tenant
            self.forSale = {}
            self.FlowTokenVault = _ftVault
            self.SimpleNFTPackage = _auth.borrow()!.getPackage(packageName: SimpleNFT.getType().identifier) as! Capability<&SimpleNFT.Package>
        }

        pub fun unlistSale(simpleNFTTenant: Address, id: UInt64) {
            self.forSale[simpleNFTTenant]!.remove(key: id)

            emit SaleWithdrawn(id: id)
        }

        // You pass in the tenant of the SimpleNFT you'll be listing for sale.
        pub fun listForSale(simpleNFTTenant: Address, ids: [UInt64], price: UFix64) {
            pre {
                price > 0.0:
                    "Cannot list a NFT for 0.0"
            }
            if self.forSale[simpleNFTTenant] == nil {
                self.forSale[simpleNFTTenant] = {}
            }

            var ownedNFTs = self.SimpleNFTPackage.borrow()!.borrowCollection(tenant: simpleNFTTenant).getIDs()
            for id in ids {
                if (ownedNFTs.contains(id)) {
                    self.forSale[simpleNFTTenant]!.insert(key: id, price)

                    emit ForSale(id: id, price: price)
                }
            }
        }

        pub fun purchase(simpleNFTTenant: Address, id: UInt64, recipient: &SimpleNFT.Collection{SimpleNFT.CollectionPublic}, buyTokens: @FungibleToken.Vault) {
            pre {
                self.forSale[simpleNFTTenant]![id] != nil:
                    "No NFT matching this id for sale!"
                buyTokens.balance >= (self.forSale[simpleNFTTenant]![id]!):
                    "Not enough tokens to buy the NFT!"
            }
            let price = self.forSale[simpleNFTTenant]![id]!
            let vaultRef = self.FlowTokenVault.borrow()!
            vaultRef.deposit(from: <-buyTokens)
            let token <- self.SimpleNFTPackage.borrow()!.borrowCollection(tenant: self.tenant).withdraw(withdrawID: id)
            recipient.deposit(token: <-token)
            self.unlistSale(simpleNFTTenant: simpleNFTTenant, id: id)
            emit NFTPurchased(id: id, price: price)
        }

        pub fun idPrice(simpleNFTTenant: Address, id: UInt64): UFix64? {
            return self.forSale[simpleNFTTenant]![id]
        }

        pub fun getIDs(simpleNFTTenant: Address): [UInt64] {
            if self.forSale[simpleNFTTenant] == nil {
                self.forSale[simpleNFTTenant] = {}
            }
            return self.forSale[simpleNFTTenant]!.keys
        }
    }

    init() {
        self.tenants <- {}

        self.PackageStoragePath = /storage/SimpleNFTMarketplacePackage
        self.PackagePrivatePath = /private/SimpleNFTMarketplacePackage
        self.PackagePublicPath = /public/SimpleNFTMarketplacePackage

        Registry.registerContract(
            proposer: self.account.borrow<&HyperverseAuth.Auth>(from: HyperverseAuth.AuthStoragePath)!, 
            metadata: HyperverseModule.ModuleMetadata(
                _identifier: self.getType().identifier,
                _contractAddress: self.account.address,
                _title: "SimpleNFT Marketplace", 
                _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalLink: "https://www.decentology.com/")], 
                _version: "0.0.1", 
                _publishedAt: getCurrentBlock().timestamp,
                _externalLink: "",
                _secondaryModules: [{Address(0x26a365de6d6237cd): "SimpleNFT"}]
            )
        )

        emit SimpleNFTMarketplaceInitialized()
    }
}