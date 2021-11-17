import IHyperverseComposable from "../Hyperverse/IHyperverseComposable.cdc"
import IHyperverseModule from "../Hyperverse/IHyperverseModule.cdc"
import HyperverseModule from "../Hyperverse/HyperverseModule.cdc"
import HyperverseAuth from "../Hyperverse/HyperverseAuth.cdc"
import HNonFungibleToken from "../Hyperverse/HNonFungibleToken.cdc"

pub contract SimpleNFT: IHyperverseModule, IHyperverseComposable, HNonFungibleToken {

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
    // Original tenantID --> actual resource
    access(contract) var tenants: @{String: IHyperverseComposable.Tenant}
    pub fun getTenant(id: String): &Tenant{IHyperverseComposable.ITenant, IState} {
        let ref = &self.tenants[id] as auth &IHyperverseComposable.Tenant
        return ref as! &Tenant
    }
    // Alias to original. Original -> actual resource above
    // So if an alias exists, it already points to a Tenant
    access(contract) var aliases: {String: String}
    pub fun addAlias(auth: &HyperverseAuth.Auth, new: String) {
        let original = auth.owner!.address.toString()
                        .concat(".")
                        .concat(self.getType().identifier)
    
        self.aliases[new] = original
    }

    pub resource interface IState {
        pub let tenantID: String
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply()
    }

    pub resource Tenant: IHyperverseComposable.ITenant, IState {
        pub let tenantID: String
        pub var totalSupply: UInt64
        access(contract) fun updateTotalSupply() {
            self.totalSupply = self.totalSupply + 1
        }
        pub var holder: Address

        init(_tenantID: String, _holder: Address) {
            self.tenantID = _tenantID
            self.totalSupply = 0
            self.holder = _holder
        }
    }

    // If we're making a new Tenant resource
    pub fun instance(auth: &HyperverseAuth.Auth) {
        pre {
            self.clientTenants[auth.owner!.address] == nil: "This account already have a Tenant from this contract."
        }
        
        var STenantID: String = auth.owner!.address.toString()
                                .concat(".")
                                .concat(self.getType().identifier)
    
        self.tenants[STenantID] <-! create Tenant(_tenantID: STenantID, _holder: auth.owner!.address)
        self.addAlias(auth: auth, new: STenantID)

        let package = auth.packages[self.getType().identifier]!.borrow()! as! &Package
        package.depositAdmin(Admin: <- create Admin(STenantID))
        package.depositMinter(NFTMinter: <- create NFTMinter(STenantID))

        self.clientTenants[auth.owner!.address] = STenantID
        emit TenantCreated(id: STenantID)
    }

    /**************************************** PACKAGE ****************************************/

    pub let PackageStoragePath: StoragePath
    pub let PackagePrivatePath: PrivatePath
    pub let PackagePublicPath: PublicPath

    pub resource interface PackagePublic {
        pub fun borrowCollectionPublic(tenantID: String): &Collection{CollectionPublic}
        pub fun depositMinter(NFTMinter: @NFTMinter)
    }

    pub resource Package: PackagePublic {
        pub var collections: @{String: HNonFungibleToken.Collection}
        pub var minters: @{String: NFTMinter}
        pub var admins: @{String: Admin}

        pub fun borrowCollection(tenantID: String): &Collection {
            let original = SimpleNFT.aliases[tenantID]!
            if self.collections[original] == nil {
                self.collections[original] <-! create Collection(tenantID)
            }
            let ref = &self.collections[original] as auth &HNonFungibleToken.Collection
            return ref as! &Collection
        }
        pub fun borrowCollectionPublic(tenantID: String): &Collection{CollectionPublic} {
            return self.borrowCollection(tenantID: tenantID)
        }

        pub fun depositMinter(NFTMinter: @NFTMinter) {
            self.minters[NFTMinter.tenantID] <-! NFTMinter
        }
        pub fun borrowMinter(tenantID: String): &NFTMinter {
            return &self.minters[SimpleNFT.aliases[tenantID]!] as &NFTMinter
        }

        pub fun depositAdmin(Admin: @Admin) {
            self.admins[Admin.tenantID] <-! Admin
        }
        pub fun borrowAdmin(tenantID: String): &Admin {
            return &self.admins[SimpleNFT.aliases[tenantID]!] as &Admin
        }

        init() {
            self.collections <- {}
            self.admins <- {}
            self.minters <- {}
        }

        destroy() {
            destroy self.collections
            destroy self.admins
            destroy self.minters
        }
    }

    pub fun getPackage(): @Package {
        return <- create Package()
    }

    /**************************************** FUNCTIONALITY ****************************************/

    pub event ContractInitialized()
    pub event Withdraw(tenantID: String, id: UInt64, from: Address?)
    pub event Deposit(tenantID: String, id: UInt64, to: Address?)

    pub resource NFT: HNonFungibleToken.INFT {
        pub let tenantID: String
        pub let id: UInt64
        pub var metadata: {String: String}
    
        init(_ tenantID: String, _metadata: {String: String}) {
            let tenant = SimpleNFT.getTenant(id: tenantID)
          
            self.id = tenant.totalSupply
            self.tenantID = tenantID
            self.metadata = _metadata

            tenant.updateTotalSupply()
        }
    }

    pub resource interface CollectionPublic {
        pub let tenantID: String
        pub fun deposit(token: @HNonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun getMetadata(id: UInt64): {String: String}
    }

    pub resource Collection: CollectionPublic, HNonFungibleToken.Provider, HNonFungibleToken.Receiver, HNonFungibleToken.CollectionPublic {
        pub let tenantID: String
        pub var ownedNFTs: @{UInt64: HNonFungibleToken.NFT}

        pub fun deposit(token: @HNonFungibleToken.NFT) {
            let token <- token as! @NFT
            let id: UInt64 = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(tenantID: self.tenantID, id: id, to: self.owner?.address)
            destroy oldToken
        }

        pub fun withdraw(withdrawID: UInt64): @HNonFungibleToken.NFT {
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(tenantID: self.tenantID, id: token.id, from: self.owner?.address)
            return <-token
        }

        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        pub fun borrowNFT(id: UInt64): &HNonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &HNonFungibleToken.NFT
        }

        pub fun getMetadata(id: UInt64): {String: String} {
            let ref = &self.ownedNFTs[id] as auth &HNonFungibleToken.NFT
            let wholeNFT = ref as! &NFT
            return wholeNFT.metadata
        }

        destroy() {
            destroy self.ownedNFTs
        }

        init (_ tenantID: String) {
            self.tenantID = tenantID
            self.ownedNFTs <- {}
        }
    }

    pub resource NFTMinter {
        pub let tenantID: String
        pub fun mintNFT(metadata: {String: String}): @NFT {
            return <- create NFT(self.tenantID, _metadata: metadata)
        }
        init(_ tenantID: String) {
            self.tenantID = tenantID
        }
    }

    pub resource Admin {
        pub let tenantID: String
        pub fun createNFTMinter(): @NFTMinter {
            return <- create NFTMinter(self.tenantID)
        }
        init(_ tenantID: String) {
            self.tenantID = tenantID
        }
    }

    init() {
        self.clientTenants = {}
        self.tenants <- {}
        self.aliases = {}

        self.PackageStoragePath = /storage/SimpleNFTPackage
        self.PackagePrivatePath = /private/SimpleNFTPackage
        self.PackagePublicPath = /public/SimpleNFTPackage

        self.metadata = HyperverseModule.ModuleMetadata(
            _title: "SimpleNFT", 
            _authors: [HyperverseModule.Author(_address: 0x26a365de6d6237cd, _externalURI: "https://www.decentology.com/")], 
            _version: "0.0.1", 
            _publishedAt: getCurrentBlock().timestamp,
            _externalURI: "",
            _secondaryModules: nil
        )

         emit ContractInitialized()
    }
}
 